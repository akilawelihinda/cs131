#!/usr/bin

from twisted.internet import reactor, protocol
from twisted.protocols.basic import LineReceiver
from twisted.python import log
from twisted.web.client import getPage
from twisted.application import service, internet

import time
import datetime
import logging
import re
import sys
import json


#used to comma-seperate the combined latlong string
def parse_latlong(latlong):
    latlong_f=latlong[1:].split("+")
    if len(latlong_f)==1:
        latlong_f=latlong[1:].split("-")
        latlong_f[1]="-"+latlong_f[1]
    else:
        latlong_f[1]="+"+latlong_f[1]
        latlong_f[0]=latlong[0]+latlong_f[0]
    latlong_string=latlong_f[0]+","+latlong_f[1]
    return latlong_string

children={
    "Alford":["Parker", "Powell"],
    "Bolden":["Parker", "Powell"],
    "Hamilton":["Parker"],
    "Parker":["Alford", "Bolden", "Hamilton"],
    "Powell":["Alford", "Bolden"]
}

server_port={
    "Alford":12430,
    "Bolden":12431,
    "Hamilton":12432,
    "Parker":12433,
    "Powell":12434
}

#protocol where server acts as client to another server during flooding
class server_as_client_protocol(LineReceiver):
    def __init__ (self,server):
        self.server=server

    def connectionMade(self):
        #when you receive a connection, send the line and
        #then immediately disconnect
        self.sendLine(self.server.message)
        self.transport.loseConnection()

    def connectionLost(self,reason):
        self.server.log("A connection was lost during flooding. Reason: "+str(reason))

#server protocol for true client
class server_protocol(LineReceiver):
    def __init__(self, server):
        self.server=server

    def connectionMade(self):
        self.server.log("New connection made.")

    def lineReceived(self, line):
        self.server.log("New line received.")
        self.server.log("REQUEST: "+line)

        #route request based on type
        reqtype=line.split(" ")[0]
        badcmd=""
        if (reqtype=="IAMAT"):
            if len(line.split(" "))==4:
                self.iamat_request(line)
            else:
                badcmd="IAMAT"
        elif (reqtype=="WHATSAT"):
            if len(line.split(" "))==4:
                self.whatsat_request(line)
            else:
                badcmd="WHATSAT"
        elif (reqtype=="AT"):
            if len(line.split(" "))==6:
                self.at_request(line)
            else:
                badcmd="AT"
        else: #unknown request
            self.server.log("Invalid line request received.")
            response="? "+line
            self.server.sendMessage(self,response)

        if badcmd!="":
            self.server.log("ERROR: "+badcmd+" command received incorrect number of arguements.")
            response="? "+line
            self.server.sendMessage(self,response)

        return

    def connectionLost(self,reason):
        self.server.log("A connection was lost. Reason: "+str(reason))

    def iamat_request(self,line):
        args=line.split(" ")
        client_id=args[1]
        latlong=args[2]
        s_time=args[3]
        c_time=float(args[3])
        diff=time.time()-c_time
        message="AT {0} {1:+f} {2}".format(self.server.name,diff,client_id+ " "+latlong+" "+s_time)

        self.server.client_list[client_id]={
            "location":parse_latlong(latlong),
            "time":s_time,
            "AT":message
        }

        #flood first, and then send response back. Want to floop asap because user could query another server later
        self.server.log("RESPONSE: "+message)
        self.server.log("Flooding.")
        self.flood(message)
        self.server.sendMessage(self,message)

    def whatsat_request(self,line):
        args=line.split(" ")
        client_id=args[1]
        radius=args[2]
        if client_id in self.server.client_list:
            position=self.server.client_list[client_id]["location"]
            query_url="https://maps.googleapis.com/maps/api/place/nearbysearch/json?"+"location={0}&radius={1}&sensor=false&key=AIzaSyBXnAvwHXpnGjN8ZJSkdc1v7Tbwev4w7JU".format(position, radius)
        else:
            message="WHATSAT ERROR OCCURRED: {0}'s location was never specified. Unknown location.".format(client_id)
            self.server.log(message)
            self.server.sendMessage(self,message)
            return message
        self.server.log("Google Query: "+query_url)
        json_data=getPage(query_url)
        cb=lambda response:(self.print_json(self.server,response, client_id))
        #adding errback to "addCallback" causes query to fail, so I ommitted it
        json_data.addCallback(callback=cb)
        self.server.log("Whatsat request deferred")

    def at_request(self,line):
        args=line.split(" ")
        diff=args[2]
        client_id=args[3]
        latlong=args[4]
        iamat_time=args[5]
        if client_id in self.server.client_list and self.server.client_list[client_id]["location"]==parse_latlong(latlong) and self.server.client_list[client_id]["time"]==iamat_time:
            message="Cycle occurred in flooding. Stop flooding."
            self.server.log("Flood Response: "+message)
            return message

        self.server.client_list[client_id]={
            "location":parse_latlong(latlong),
            "time":iamat_time,
            "AT":line
        }

        #flood asap to spread message as fast as possible. log afterwards
        self.flood(line)
        message="Received following during a flood: "+str(line)
        self.server.log(message)
        return

    def flood(self,at_request):
        for child in children[self.server.name]:
            reactor.connectTCP('localhost', server_port[child], server_as_client(at_request))
        return

    #callback function, which logs Google's api respsonse and sends client response
    def print_json(self,server,response,client_id):
        json_body=json.loads(response)
        message=str(self.server.client_list[client_id]["AT"])+"\n"+str(json.dumps(json_body, indent=4))+"\n"
        server.log("Deferred Whatsat request is being serviced now.")
        server.log("Entire Google Places response to Whatsat request:\n"+message)
        self.transport.write(message)

class server_as_client(protocol.ClientFactory):
    def __init__(self,req):
        self.message=req

    def buildProtocol(self,temp):
        return server_as_client_protocol(self)

    def log(self,message):
        logging.info(message)

class server(protocol.ServerFactory):
    def __init__(self,name):
        self.name=name
        self.client_list=dict()
        filepath=name+".log"
        logging.basicConfig(level=logging.INFO,filename=filepath)
        self.log(name+" has started running")

    def buildProtocol(self, temp):
        return server_protocol(self)

    def log(self,message):
        logging.info(message)

    def sendMessage(self,protocol,message):
        protocol.transport.write(message+"\n")

    def stopFactory(self):
        self.log(self.name+" is now shutting down.")

def run():
    #main logic of program which actually creates server instance and starts event-listener
    new_server=server(sys.argv[1])
    reactor.listenTCP(server_port[sys.argv[1]],new_server)
    reactor.run()

#run in top level module only(in case of existence test scripts)
if __name__=="__main__":
    run()
