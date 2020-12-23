using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Math;

class TextField extends Ui.Drawable {

	var options;
	var curText;
	var backgroundColor;
	var defaultBackgroundColor;
	
	function initialize(options) {
		Drawable.initialize(options);
		self.options = options;
		self.curText = options[:initText];
		self.defaultBackgroundColor = options[:backgroundColor];
		self.backgroundColor = options[:backgroundColor];
	}
	
	function setText(text) {
		self.curText = text;
	}
	
	function setDefaultBackgroundColor() {
		self.backgroundColor = self.defaultBackgroundColor;
	}
	
	function setBackgroundColor(color) {
		self.backgroundColor = color;
	}
	
	function setTextWithUIUpdate(text) {
		self.curText = text;
		Ui.requestUpdate();
	}
	
	function draw(dc) {
	
		var startX = options[:startWidthPerc].size();
		var startY = options[:startHeightPerc].size();
		
		for (var i = 0; i < options[:startWidthPerc].size(); i++) {
			startX += Math.floor(dc.getWidth() * options[:startWidthPerc][i]);
		}
		
		for (var i = 0; i < options[:startHeightPerc].size(); i++) {
			startY += Math.floor(dc.getHeight() * options[:startHeightPerc][i]);
		}
	
		var width = dc.getWidth() * options[:widthPerc];
		var height = dc.getHeight() * options[:heightPerc];
		dc.setColor(backgroundColor, Graphics.COLOR_DK_GRAY);
		dc.fillRectangle(startX, startY, width, height);
		
		if (!options.hasKey(:omitText)) {
		
			dc.setColor(0xAB6AB5, Graphics.COLOR_TRANSPARENT);
			
			if (options[:widthPerc] != 1.0) {
				// Draw right border
				dc.drawLine(startX + width, startY, startX + width, startY + height);
			}
			
			// Draw bottom border
			dc.drawLine(startX, startY + height, startX + width, startY + height);
			
			// Draw Text		
			var font = Ui.loadResource(options[:font]);
			
			var textDimensions = dc.getTextDimensions(curText, font);
			var startTextX = startX + ((width - textDimensions[0]) / 2);
			var startTextY = startY + ((height - textDimensions[1]) / 2);
			
			if (!options[:unitsInline]) {
				startTextY -= 10;
			}
			
			if (options.hasKey(:textColor)) {
				dc.setColor(options[:textColor], Graphics.COLOR_TRANSPARENT);
			} else {
				dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
			}
			
			dc.drawText(startTextX, startTextY, font, curText, Graphics.TEXT_JUSTIFY_LEFT);
					
			// Draw Unit Label
			if (options[:hasUnitLabel]) {
	
				var unitFont = Ui.loadResource(options[:unitLabelFont]);
				var labelFontDims = dc.getTextDimensions(options[:unitsLabel], unitFont);
				
				if (options[:unitsInline]) {
					var startLabelX = startTextX + textDimensions[0] + options[:labelHorizontalPadding];
					var startLabelY = startTextY + textDimensions[1] - labelFontDims[1] - options[:labelVerticalPadding];
					
					dc.drawText(startLabelX, startLabelY, unitFont, options[:unitsLabel], Graphics.TEXT_JUSTIFY_LEFT);
				} else {
					var startLabelX = startX + ((width - labelFontDims[0]) / 2);
					var startLabelY = startTextY + dc.getFontAscent(font) + options[:labelVerticalPadding];
					
					dc.drawText(startLabelX, startLabelY, unitFont, options[:unitsLabel], Graphics.TEXT_JUSTIFY_LEFT);
				}
				
			}
		}
	}
}











