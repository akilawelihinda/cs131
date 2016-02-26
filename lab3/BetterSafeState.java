import java.util.concurrent.locks.ReentrantLock;

class BetterSafeState implements State {
    private byte[] value;
    private byte maxval;
	private ReentrantLock critical;

    BetterSafeState(byte[] v) {
		value = v;
		maxval = 127;
		critical=new ReentrantLock();
	}

    BetterSafeState(byte[] v, byte m) {
		value = v;
		maxval = m;
		critical=new ReentrantLock();
	}

    public int size() { return value.length; }

    public byte[] current() { return value; }

    public boolean swap(int i, int j) {
		critical.lock();		
		if (value[i] <= 0 || value[j] >= maxval) {
			critical.unlock();
			return false;
		}
		value[i]--;
		value[j]++;
		critical.unlock();
		return true;
    }
}
