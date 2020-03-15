class Line {
	private var xStart;
	private var xEnd;
	private var yStart;
	private var yEnd;
	
	function initialize(xStart, xEnd, yStart, yEnd) {
		self.xStart = xStart;
		self.xEnd = xEnd;
		self.yStart = yStart;
		self.yEnd = yEnd;
	}
	
	function getXstart() {
		return self.xStart;
	}
	
	function getXend() {
		return self.xEnd;
	}
	
	function getYstart() {
		return self.yStart;
	}
	
	function getYend() {
		return self.yEnd;
	}
}