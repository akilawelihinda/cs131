import java.util.concurrent.atomic.AtomicIntegerArray;

class GetNSetState implements State {
    private AtomicIntegerArray value;
    private byte maxval;

    GetNSetState(byte[] v) { 
		value=new AtomicIntegerArray(v.length);
		for(int x=0;x<v.length;x++)
			value.set(x,v[x]);
		 maxval = 127; 
	}

    GetNSetState(byte[] v, byte m) {
		this(v);
		maxval = m;
	}

    public int size() { return value.length(); }

    public byte[] current() {
		byte[] retval=new byte[value.length()];
		for(int x=0;x<value.length();x++)
			retval[x]=(byte)value.get(x);
		return retval;
	}

    public boolean swap(int i, int j) {
    if (value.get(i) <= 0 || value.get(j) >= maxval) {
        return false;
    }
    value.set(i,value.get(i)-1);
    value.set(j,value.get(j)+1);
    return true;
    }
}
