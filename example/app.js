// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var win = Ti.UI.createWindow({
	backgroundColor:'white'
});

var TiYukkuri = require('com.xtity.mod.TiYukkuri');
Ti.API.info("module is => " + TiYukkuri);

// Text Field
var tf = Ti.UI.createTextField({
	width: 200
	,height: 32
	,value: 'ゆっくりしていってね'
	,returnKeyType: Ti.UI.RETURNKEY_DONE
	,borderStyle: Ti.UI.INPUT_BORDERSTYLE_ROUNDED
	,clearButtonMode: Ti.UI.INPUT_BUTTONMODE_ONFOCUS
	,layout: 'vertical'
});

tf.addEventListener('return', function(e){
	tf.blur();
});

win.add(tf);

// picker
var voiceKindNames = [
	'aq_f1c.phont'
	,'aq_f3a.phont'
	,'aq_huskey.phont'
	,'aq_m4b.phont'
	,'aq_mf1.phont'
	,'aq_rb2.phont'
	,'aq_rb3.phont'
	,'aq_rm.phont'
	,'aq_robo.phont'
	,'aq_yukkuri.phont'
	,'ar_f4.phont'
	,'ar_m5.phont'
	,'ar_mf2.phont'
	,'ar_rm3.phont'
];

var picker = Ti.UI.createPicker({
	top:50
	,useSpinner: true
	,layout: 'vertical'
});
picker.selectionIndicator = true;

var column = Ti.UI.createPickerColumn();

for(var i=0, ilen=voiceKindNames.length; i<ilen; i++){
	var row = Ti.UI.createPickerRow({
		title: voiceKindNames[i]
	});
	column.addRow(row);
}

picker.add([column]);
win.add(picker);

// button
var button = Titanium.UI.createButton({
	title: 'say'
	,top: 30
	,layout: 'vertical'
});
button.addEventListener('click', function() {
	TiYukkuri.say({
		word: tf.value
		,voiceKindName: picker.getSelectedRow(0).title
	});
});

win.add(button);

win.open();

// if (Ti.Platform.name == "android") {
	// var proxy = TiYukkuri.createExample({
		// message: "Creating an example Proxy",
		// backgroundColor: "red",
		// width: 100,
		// height: 100,
		// top: 100,
		// left: 150
	// });
// 
	// proxy.printMessage("Hello world!");
	// proxy.message = "Hi world!.  It's me again.";
	// proxy.printMessage("Hello world!");
	// win.add(proxy);
// }

