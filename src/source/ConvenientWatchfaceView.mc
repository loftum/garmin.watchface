using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.System;
using Toybox.Lang;
using Toybox.Application;

class ConvenientWatchfaceView extends WatchUi.WatchFace {
	
	private var centerX;
	private var centerY;
	private var radius;
	private var backgroundColor;
	private var markers;

    function initialize() {
        
        var settings = System.getDeviceSettings();
		centerX = Math.floor(settings.screenWidth / 2);
		centerY = Math.floor(settings.screenHeight / 2);
		radius = Math.floor(settings.screenHeight / 2 - 1);
		backgroundColor = Application.getApp().getProperty("BackgroundColor");
		var length = radius * 0.15;
		markers = new [12];
		for(var ii=0; ii<12; ii++) {
			var angle =  Math.PI / 2 - ii * Math.PI / 6;
			var xStart = centerX + Math.cos(angle) * radius;
			var xEnd = centerX + Math.cos(angle) * (radius - length);
			var yStart = centerY - Math.sin(angle) * radius;
			var yEnd = centerY - Math.sin(angle) * (radius - length);
			markers[ii] = new Line(xStart, xEnd, yStart, yEnd);
		}
		
		WatchFace.initialize();
    }

    // Load your resources here
    function onLayout(dc) {
        setLayout(Rez.Layouts.WatchFace(dc));
        getRight().setColor(backgroundColor);
        getRight().setBackgroundColor(Graphics.COLOR_DK_GRAY);
        getRight().setText("right");
        getBottom().setText("bottom");
    }
    
    function getLeft() {
        return View.findDrawableById("LeftLabel");
    }

    function getTop() {
        return View.findDrawableById("TopLabel");
    }

    function getRight() {
        return View.findDrawableById("RightLabel");
    }

    function getBottom() {
        return View.findDrawableById("BottomLabel");
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
		
        // Update the view
        var view = View.findDrawableById("TimeLabel");
        view.setColor(Application.getApp().getProperty("ForegroundColor"));

		var stats = System.getSystemStats();
        getLeft().setText(getHeartRate());
        
        

        // Call the parent onUpdate function to redraw the layout
        drawDigital();
        drawDate();
        View.onUpdate(dc);
        drawBatteryArc(dc);
        //drawMarkers(dc);
        drawMarkersWithBattery(dc);
        drawHands(dc);
    }
    
    function getHeartRate() {
    	var heartRate = Activity.Info.currentHeartRate;
		if (heartRate != null) {
			return Lang.format("$1c", [heartRate]);
		}
		
		var history = SensorHistory.getHeartRateHistory({:period => 1});
		var sample = history.next();
		
		if (sample != null && sample.data != ActivityMonitor.INVALID_HR_SAMPLE){
			return Lang.format("$1$h", [sample.data]);
		}
		
		return "--";
    }
    
    function drawDate() {
    	var day = Time.Gregorian.info(Time.now(), Time.FORMAT_MEDIUM).day;
    	if (day != null) {
    		getRight().setText(day.toString());
    		return;
    	}
    	
    	getRight().setText("--");
    }
    
    function drawDigital() {
    	// Get the current time and format it correctly
        var timeFormat = "$1$:$2$";
        var clockTime = System.getClockTime();
        
        var hours = clockTime.hour;
        if (!System.getDeviceSettings().is24Hour) {
            if (hours > 12) {
                hours = hours - 12;
            }
        } else {
            if (Application.getApp().getProperty("UseMilitaryFormat")) {
                timeFormat = "$1$$2$";
                hours = hours.format("%02d");
            }
        }
        var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
		getTop().setText(timeString);
    }
    
    function drawHands(dc) {
    	var time = System.getClockTime();
    	
    	var minuteAngle = Math.PI / 2 - Math.PI / 30 * time.min;
    	dc.setPenWidth(2);
    	dc.setColor(Graphics.COLOR_DK_GRAY, backgroundColor);
    	dc.drawLine(centerX, centerY, centerX + Math.cos(minuteAngle) * radius * 0.7, centerY - Math.sin(minuteAngle) * radius * 0.7);
    	
    	var hour = time.hour <= 12 ? time.hour : time.hour - 12;
    	var hourAngle = Math.PI / 2 - Math.PI / 6 * hour  - Math.PI / 6 / 60 * time.min;
    	dc.setPenWidth(3);
    	dc.setColor(Graphics.COLOR_DK_GRAY, backgroundColor);
    	dc.drawLine(centerX, centerY, centerX + Math.cos(hourAngle) * radius * 0.5, centerY - Math.sin(hourAngle) * radius * 0.5); 
    }
    
    function drawMarkers(dc) {
    	dc.setPenWidth(1);
		dc.setColor(Graphics.COLOR_DK_GRAY, backgroundColor);
    	for(var ii=0; ii<markers.size(); ii++) {
    		var marker = markers[ii];
    		dc.drawLine(marker.getXstart(), marker.getYstart(), marker.getXend(), marker.getYend());
    	}
    }
    
    function drawMarkersWithBattery(dc) {
    	var stats = System.getSystemStats();
    	var count = stats.battery / 100 * 12; 
    	dc.setPenWidth(2);
    	dc.setColor(getBatteryColor(stats.battery), backgroundColor);
    	for(var ii=0; ii<markers.size(); ii++) {
    		var marker = markers[ii];
    		if (ii > count) {
    			dc.setPenWidth(1);
    			dc.setColor(Graphics.COLOR_DK_GRAY, backgroundColor);
    		}
    		dc.drawLine(marker.getXstart(), marker.getYstart(), marker.getXend(), marker.getYend());
    	}
    }
    
    function drawBatteryArc(dc) {
    	var stats = System.getSystemStats();
    	dc.setPenWidth(1);
        //dc.setColor(getBatteryColor(stats.battery), backgroundColor);
        dc.setColor(getBatteryColor(stats.battery), Graphics.COLOR_WHITE);
        dc.drawArc(centerX, centerY, radius, Graphics.ARC_CLOCKWISE, 90, 90 - 3.60 * stats.battery);
    }
    
    function getBatteryColor(battery) {
    	if (battery >= 50) {
    		return 0x00ff00;
    	}
    	if (battery >= 30) {
    		return 0xffff00;
    	}
    	if (battery >= 25) {
    		return 0xff5500;
    	}
    	return 0xff0000;
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}
