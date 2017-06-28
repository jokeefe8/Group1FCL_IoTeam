import org.jnetpcap.util.PcapPacketArrayList;

public class mcl {
	public static void main(String [] args) {
		// the included pcapng file might have to be turned into a pcap file before processing. 
		PCapHandler pcap = new PCapHandler(Config.capture_file);
		
		try {
			PcapPacketArrayList p_arr = pcap.readOfflineFiles();
			p_arr.get(1).getCaptureHeader().toString();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
}
