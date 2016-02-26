python application_server_herd.py Alford &
python application_server_herd.py Bolden &
python application_server_herd.py Hamilton &
python application_server_herd.py Parker &
python application_server_herd.py Powell &
#let servers come online
sleep 2

#sleep before every test-case to allow for flooding and such

sleep 2 #alford
(echo "IAMAT akila +37-120 1448852432" ; sleep 1) | telnet localhost 12430

sleep 2 #bolden
(echo "IAMAT akila +36.56789-119.789 1448852432" ; sleep 1) | telnet localhost 12431

sleep 2 #alford
(echo "WHATSAT akila 20 5" ; sleep 1) | telnet localhost 12430


sleep 2 #hamilton
(echo "IAMAT guy +38-118 1448852432" ; sleep 1) | telnet localhost 12432

#force Parker to go down and observe the behavior of disconnected graph
pkill -f 'python application_server_herd.py Parker'
sleep 2 #hamilton
(echo "IAMAT guy +38.555-118.555 1448852432" ; sleep 1) | telnet localhost 12432
sleep 2 #bolden
(echo "WHATSAT guy 20 5" ; sleep 1) | telnet localhost 12431


pkill -f 'python application_server_herd.py Alford'
pkill -f 'python application_server_herd.py Bolden'
pkill -f 'python application_server_herd.py Hamilton'
pkill -f 'python application_server_herd.py Parker'
pkill -f 'python application_server_herd.py Powell'
