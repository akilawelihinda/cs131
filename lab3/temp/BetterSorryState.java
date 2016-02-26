import java.util.concurrent.locks.ReentrantLock;

class BetterSorryState implements State {
    private byte[] value;
    private byte maxval;
    private ReentrantLock[] criticals;

    BetterSorryState(byte[] v) {
        value = v;
        maxval = 127;
        criticals=new ReentrantLock[v.length];
		for(int x=0;x<v.length;x++)
			criticals[x]=new ReentrantLock();
    }

    BetterSorryState(byte[] v, byte m) {
		this(v);
        maxval = m;
    }

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
        if (value[i] <= 0 || value[j] >= maxval) {
            return false;
        }
		if(criticals[i].tryLock() && criticals[j].tryLock()){
        	value[i]--;
        	value[j]++;
		}
        return true;
    }
}
