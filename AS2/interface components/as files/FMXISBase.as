/**
   <p>All of the FMXIS components inherit listener functionality through this
   component, FMXISBase.  More than just EventDispatcher, this component sets
   up the listener mechanism to accept instances (like EventDispatcher) or
   listener name(s) (strings) to evaluate the listener at each
   event-notification time, rather than instantiation time (like addEventListener).</p>
   
   <p>Since FMXISBase is designed as the foundation for all FMXIS components, it is
   a subclass of UIComponent, and therefore inherits methods and properties for
   the Flash v2 architecture.  This component provides the following methods of its own:</p>
   
   <li><code>addEventListener</code> - Adds the given listener instance to the component, only for the specified event</li>
   <li><code>removeEventListener</code> - Remove the given listener instance</li>
   <li><code>addProxyListener</code> - Adds the given listener name to the component's list for a specific
   given set of events</li>
   <li><code>removeProxyListener</code> - Removes the specified listener from the component's list</li>
   <li><code>addListener</code> - Adds the given listener name or object to the component's list, but for all events generated</li>
   <li><code>removeListener</code> - Removes the specified listener from the component's list</li>
   <li><code>dispatchEvent</code> - Broadcasts an event to all listeners on the component's list</li>
   
   <p>Events are broadcast to a method on the listener called handleEvent, if it exists,
   or to the specific method with the name of the event.</p>
   
   <p>By default, FMXISBase has a single public component property, listener.  This is inherited
   and used for convenience so users can type in at least one listener right in the
   component property inspector (rather than requiring programmatic hookup).  This is
   an abstract class because while it provides listener functionality, it doesn't generate
   any events itself.</p>
   
   <p>For efficiency, it keeps track of the list of events that the component generates.  It
   also defines an event object that subclasses can reuse as they generate events.  We
   did this rather than dynamically create a new event object on each dispatch.</p>
      
   @class FMXISBase
   @package mx.fmxis
   @author Jonathan Kaye (FlashSim.com)
   @tooltip Base class for FMXIS component listener behaviors
*/
/*
This code was developed by Jonathan Kaye and Amethyst Interactive LLC,
Copyright 2002-2004, all rights reserved.
v2.0, February, 2004
*/
import mx.core.UIObject;
import mx.events.EventDispatcher;
import mx.fmxis.FMXISProxyListener;

/**
This method allows the developer to register a listener object to receive event notification
for the specific event, given by name.  This method is provided by mx.events.EventDispatcher.

@method addEventListener
@param eventName String name of the event to listen for
@param inst Listener instance
*/

/**
This method removes the listener specified from those notified when the specified event is generated.
This method is provided by mx.events.EventDispatcher.

@method removeEventListener
@param eventName String name of the event to listen for
@param inst Listener instance
*/

/**
<p>Components call this method when they want to generate an event.  The one parameter is
an object with at least two properties defined: <code>type</code> (the event name), and <code>target</code>,
the component instance.  For space efficiency, FMXISBase defines a single object, called <code>eventObj</code>,
that components can reuse as the event instance (simply change the event name and any other properties you
want to pass to the event handler).</p>
<p>This method is provided by mx.events.EventDispatcher.</p>

@method dispatchEvent
@param eventName String name of the event to listen for
@param inst Listener instance
*/

class mx.fmxis.FMXISBase extends mx.core.UIComponent {
	
	var className:String = "FMXISBase";
	static var symbolOwner:Object = FMXISBase;
	static var symbolName:String = "FMXISBase";

	private var boundingBoxClip:MovieClip;

	/**
	<p>The listener property is designed for convenience at component instantiation time.  It is
	the string name of a listener to register on this component.  Developers can certainly register
	listeners programmatically through <code>addListener()</code> or <code>addEventListener()</code>,
	but this property makes it convenient to add the first listener -- in many cases, there is only one.</p>

	<p>FMXISBase simply takes this property at initialization time and calls <code>addProxyListener()</code>.
	Therefore, developers can also prefix the name by a relative (e.g., _parent) or absolute (e.g., _root,
	_level, or _global) path.</p>
	
	@property listener
	*/
	[Inspectable(name="Listener instance name", type=String, defaultValue="")]
	private var listener:String;
	private var eventObj:Object;
	
	// listener registration stuff
	static private var _BCastMixin = EventDispatcher.initialize(FMXISBase.prototype);
	private var dispatchEvent:Function;
	public var addEventListener:Function;
	public var removeEventListener:Function;
	
	// This is an internal array of listeners we create when the user
	// has specified an instance name string, rather than an instance.  In that
	// case, we have to create an intermediate listener, for the sake of addEventListener(),
	// since that requires an instance.
	private var myProxyListeners:Array;
	
	// Used by subclasses to hold list of events.  Subclasses must override this
	// property with an array of event names, if the component generates any events.
	private var myEvents;
	
	// For compatibility with Flash 6
	var clipParameters:Object = {  listener:1 };
	private static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(FMXISBase.prototype.clipParameters, 
                               UIObject.prototype.clipParameters);


	// constructor
	function FMXISBase () {
	}
	
	function init (evts) {
		// we hold onto the _xscale and _yscale because UIComponent will set scaling to 100%
		// Our components want to preserve this and set the size itself.
		var mx = _xscale, my = _yscale;

		super.init();

		_xscale = mx;
		_yscale = my;
		
		this.boundingBoxClip._visible = false;

		// Checks to see if user set a listener name in the property inspector.  If so,
		// register the listener to receive this component's event notification.
		addProxyListener(listener, evts);
		
		// By default, we create a single event objects to reuse as events are generated
		eventObj = new Object();
		eventObj.target = this;
	}
	
	
	/**
	Register the listener programmatically to receive <b>all</b> events for this component.
	We can accept the listener if it is an instance name (use addEventListener directly)
	or the string name of the listener (then we add a proxy listener).
	
	@method addListener
	@param lstner The listener's instance or string name (with or without relative or absolute path)
	*/
	public function addListener(lstnr) {
		if (lstnr instanceof Object) {
			for (var i=0; i<myEvents.length; i++) {
				this.addEventListener(myEvents[i], lstnr);
			}
		} else {
			addProxyListener(lstnr);
		}
	}
	
	/**
	Remove the listener from this component's event notification list.  Inside, we see if the listener specified
	is an instance or a string, then call the appropriate removal routine to clean up.
	@method removeListener
	@param lstnr
	*/
	public function removeListener(lstnr) {
		if (lstnr instanceof Object) {
			for (var i=0; i<myEvents.length; i++) {
				this.removeEventListener(myEvents[i], lstnr);
			}
			
		} else {
			removeProxyListener(lstnr);
		}
	}
	
	
	/**
	This adds a listener instance name (string) to the list of listeners.  The name
	may carry a relative or absolute path (_parent, _level, _global, etc.). If evts
	is undefined, use the existing list of events for this component (from myEvents,
	which subclasses that have events must override).  If evts is not undefined, then
	it is an array containing elements that are event names (strings) for each event
	that the listener wants to hear.
	
	@method addProxyListener
	@param listenerName String name of the listener instance
	@param evts Array of events to register listener for, leave undefined for all component events
	*/
	private function addProxyListener(listenerName, evts:Array) {
		var thisPL:FMXISProxyListener, len:Number, timeline = this._parent, already=false;

		if (listenerName != "" && listenerName != undefined) {
			// See if there are any absolute or relative paths.  If so, adjust the
			// timeline to an appropriate object and listener name to a string.
			if (listenerName.indexOf(".") != -1) {
				var pfx = listenerName.toUpperCase(), lastDot:Number, fullPfx:String;
				
				lastDot = pfx.lastIndexOf(".");
				fullPfx = listenerName.substr(0, lastDot).toLowerCase();				
				if (pfx.substr(0, 7) == "_PARENT") {
					timeline = eval("this._parent." + fullPfx);
				} else {
					timeline = eval(fullPfx);
				}
				listenerName = listenerName.substr(lastDot+1);
			}
		
			if (evts == undefined) {
				evts = myEvents;
			}
			
			if (myProxyListeners == undefined) {
				myProxyListeners = new Array(new FMXISProxyListener(timeline, listenerName));
			} else {
				for (var i=0; i<myProxyListeners.length; i++) {
					if (myProxyListeners[i].lstner == listenerName &&
						myProxyListeners[i].tline  == timeline) {
						already = true;
						break;
					}
				}
				if (already)
					return;
					
				myProxyListeners.push(new FMXISProxyListener(timeline, listenerName));
			}
			
			thisPL = myProxyListeners[myProxyListeners.length-1];
		
			len = evts.length;
			for (var i=0; i<len; i++) {
				this.addEventListener(evts[i], thisPL);
			}
		}
	}
	
	/**
	Removes the given listener (listenerName) from our records, and event notification.  If
	the listener was added with a relative or absolute path, then it must be removed with a path
	that gets to the correct timeline as well, even if that prefix is different from when the listener
	was added (for example, if the handler removing the listener is on a different timeline than the
	one that added the listener).
	
	@method removeProxyListener
	@param listenerName Listener instance name (string)
	*/
	private function removeProxyListener(listenerName) {
		var thisPL:FMXISProxyListener, MPLs:Number = myProxyListeners.length,
			MEs:Number = myEvents.length, timeline:MovieClip = this._parent;
		
		// See if there are any absolute or relative paths.  If so, adjust the
		// timeline to an appropriate object and listener name to a string.
		if (listenerName.indexOf(".") != -1) {
			var pfx = listenerName.toUpperCase(), lastDot:Number, fullPfx:String;
			
			lastDot = pfx.lastIndexOf(".");
			fullPfx = listenerName.substr(0, lastDot).toLowerCase();				
			if (pfx.substr(0, 7) == "_PARENT") {
				timeline = eval("this._parent." + fullPfx);
			} else {
				timeline = eval(fullPfx);
			}
			listenerName = listenerName.substr(lastDot+1);
		}
			
		if (myProxyListeners != undefined) {
			for (var i=0; i<MPLs; i++) {
				if (myProxyListeners[i].lstner == listenerName && myProxyListeners[i].tline == timeline) {
					thisPL = myProxyListeners[i];
					for (var j=0; i<MEs; i++) {
						this.removeEventListener(myEvents[i], thisPL);
					}
					myProxyListeners.splice(i, 1);
					break;
				}
			}
		}
	}
}