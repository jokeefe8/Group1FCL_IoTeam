import java.util.ArrayList;
import java.io.BufferedReader;
import java.io.FileNotFoundException;
import java.io.FileReader;
import 

public class Parser {
	public ArrayList<Packet> PacketList;
	
	public Parser() {
		PacketList = new ArrayList<Packet>();
	}
	
	public void readCsv(String filename) {
		
	}
	
	public class Packet {
		public String time;
		public String src;
		public String dst;
		public String protocol;
		public String length;
		public String info;
		
		public Packet(String t, String s, String d, String p, String l, String i) {
			time = t;
			src = s;
			dst = d;
			protocol = p;
			length = l;
			info = i;
		}
	}
}
