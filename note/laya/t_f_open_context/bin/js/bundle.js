var __extends = (this && this.__extends) || (function () {
    var extendStatics = Object.setPrototypeOf ||
        ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
        function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
(function(){function r(e,n,t){function o(i,f){if(!n[i]){if(!e[i]){var c="function"==typeof require&&require;if(!f&&c)return c(i,!0);if(u)return u(i,!0);var a=new Error("Cannot find module '"+i+"'");throw a.code="MODULE_NOT_FOUND",a}var p=n[i]={exports:{}};e[i][0].call(p.exports,function(r){var n=e[i][1][r];return o(n||r)},p,p.exports,r,e,n,t)}return n[i].exports}for(var u="function"==typeof require&&require,i=0;i<t.length;i++)o(t[i]);return o}return r})()({1:[function(require,module,exports){

/***********************************/
/*http://www.layabox.com  2017/12/12*/
/***********************************/
var Laya=window.Laya=(function(window,document){
	var Laya={
		__internals:[],
		__packages:{},
		__classmap:{'Object':Object,'Function':Function,'Array':Array,'String':String},
		__sysClass:{'object':'Object','array':'Array','string':'String','dictionary':'Dictionary'},
		__propun:{writable: true,enumerable: false,configurable: true},
		__presubstr:String.prototype.substr,
		__substr:function(ofs,sz){return arguments.length==1?Laya.__presubstr.call(this,ofs):Laya.__presubstr.call(this,ofs,sz>0?sz:(this.length+sz));},
		__init:function(_classs){_classs.forEach(function(o){o.__init$ && o.__init$();});},
		__isClass:function(o){return o && (o.__isclass || o==Object || o==String || o==Array);},
		__newvec:function(sz,value){
			var d=[];
			d.length=sz;
			for(var i=0;i<sz;i++) d[i]=value;
			return d;
		},
		__extend:function(d,b){
			for (var p in b){
				if (!b.hasOwnProperty(p)) continue;
				var gs=Object.getOwnPropertyDescriptor(b, p);
				var g = gs.get, s = gs.set; 
				if ( g || s ) {
					if ( g && s)
						Object.defineProperty(d,p,gs);
					else{
						g && Object.defineProperty(d, p, g);
						s && Object.defineProperty(d, p, s);
					}
				}
				else d[p] = b[p];
			}
			function __() { Laya.un(this,'constructor',d); }__.prototype=b.prototype;d.prototype=new __();Laya.un(d.prototype,'__imps',Laya.__copy({},b.prototype.__imps));
		},
		__copy:function(dec,src){
			if(!src) return null;
			dec=dec||{};
			for(var i in src) dec[i]=src[i];
			return dec;
		},
		__package:function(name,o){
			if(Laya.__packages[name]) return;
			Laya.__packages[name]=true;
			var p=window,strs=name.split('.');
			if(strs.length>1){
				for(var i=0,sz=strs.length-1;i<sz;i++){
					var c=p[strs[i]];
					p=c?c:(p[strs[i]]={});
				}
			}
			p[strs[strs.length-1]] || (p[strs[strs.length-1]]=o||{});
		},
		__hasOwnProperty:function(name,o){
			o=o ||this;
		    function classHas(name,o){
				if(Object.hasOwnProperty.call(o.prototype,name)) return true;
				var s=o.prototype.__super;
				return s==null?null:classHas(name,s);
			}
			return (Object.hasOwnProperty.call(o,name)) || classHas(name,o.__class);
		},
		__typeof:function(o,value){
			if(!o || !value) return false;
			if(value===String) return (typeof o==='string');
			if(value===Number) return (typeof o==='number');
			if(value.__interface__) value=value.__interface__;
			else if(typeof value!='string')  return (o instanceof value);
			return (o.__imps && o.__imps[value]) || (o.__class==value);
		},
		__as:function(value,type){
			return (this.__typeof(value,type))?value:null;
		},
        __int:function(value){
            return value?parseInt(value):0;
        },
		interface:function(name,_super){
			Laya.__package(name,{});
			var ins=Laya.__internals;
			var a=ins[name]=ins[name] || {self:name};
			if(_super)
			{
				var supers=_super.split(',');
				a.extend=[];
				for(var i=0;i<supers.length;i++){
					var nm=supers[i];
					ins[nm]=ins[nm] || {self:nm};
					a.extend.push(ins[nm]);
				}
			}
			var o=window,words=name.split('.');
			for(var i=0;i<words.length-1;i++) o=o[words[i]];
			o[words[words.length-1]]={__interface__:name};
		},
		class:function(o,fullName,_super,miniName){
			_super && Laya.__extend(o,_super);
			if(fullName){
				Laya.__package(fullName,o);
				Laya.__classmap[fullName]=o;
				if(fullName.indexOf('.')>0){
					if(fullName.indexOf('laya.')==0){
						var paths=fullName.split('.');
						miniName=miniName || paths[paths.length-1];
						if(Laya[miniName]) console.log("Warning!,this class["+miniName+"] already exist:",Laya[miniName]);
						Laya[miniName]=o;
					}
				}
				else {
					if(fullName=="Main")
						window.Main=o;
					else{
						if(Laya[fullName]){
							console.log("Error!,this class["+fullName+"] already exist:",Laya[fullName]);
						}
						Laya[fullName]=o;
					}
				}
			}
			var un=Laya.un,p=o.prototype;
			un(p,'hasOwnProperty',Laya.__hasOwnProperty);
			un(p,'__class',o);
			un(p,'__super',_super);
			un(p,'__className',fullName);
			un(o,'__super',_super);
			un(o,'__className',fullName);
			un(o,'__isclass',true);
			un(o,'super',function(o){this.__super.call(o);});
		},
		imps:function(dec,src){
			if(!src) return null;
			var d=dec.__imps|| Laya.un(dec,'__imps',{});
			function __(name){
				var c,exs;
				if(! (c=Laya.__internals[name]) ) return;
				d[name]=true;
				if(!(exs=c.extend)) return;
				for(var i=0;i<exs.length;i++){
					__(exs[i].self);
				}
			}
			for(var i in src) __(i);
		},
        superSet:function(clas,o,prop,value){
            var fun = clas.prototype["_$set_"+prop];
            fun && fun.call(o,value);
        },
        superGet:function(clas,o,prop){
            var fun = clas.prototype["_$get_"+prop];
           	return fun?fun.call(o):null;
        },
		getset:function(isStatic,o,name,getfn,setfn){
			if(!isStatic){
				getfn && Laya.un(o,'_$get_'+name,getfn);
				setfn && Laya.un(o,'_$set_'+name,setfn);
			}
			else{
				getfn && (o['_$GET_'+name]=getfn);
				setfn && (o['_$SET_'+name]=setfn);
			}
			if(getfn && setfn) 
				Object.defineProperty(o,name,{get:getfn,set:setfn,enumerable:false,configurable:true});
			else{
				getfn && Object.defineProperty(o,name,{get:getfn,enumerable:false,configurable:true});
				setfn && Object.defineProperty(o,name,{set:setfn,enumerable:false,configurable:true});
			}
		},
		static:function(_class,def){
				for(var i=0,sz=def.length;i<sz;i+=2){
					if(def[i]=='length') 
						_class.length=def[i+1].call(_class);
					else{
						function tmp(){
							var name=def[i];
							var getfn=def[i+1];
							Object.defineProperty(_class,name,{
								get:function(){delete this[name];return this[name]=getfn.call(this);},
								set:function(v){delete this[name];this[name]=v;},enumerable: true,configurable: true});
						}
						tmp();
					}
				}
		},		
		un:function(obj,name,value){
			value || (value=obj[name]);
			Laya.__propun.value=value;
			Object.defineProperty(obj, name, Laya.__propun);
			return value;
		},
		uns:function(obj,names){
			names.forEach(function(o){Laya.un(obj,o)});
		}
	};

    window.console=window.console || ({log:function(){}});
	window.trace=window.console.log;
	Error.prototype.throwError=function(){throw arguments;};
	//String.prototype.substr=Laya.__substr;
	Object.defineProperty(Array.prototype,'fixed',{enumerable: false});

	return Laya;
})(window,document);

(function(window,document,Laya){
	var __un=Laya.un,__uns=Laya.uns,__static=Laya.static,__class=Laya.class,__getset=Laya.getset,__newvec=Laya.__newvec;
Laya.interface('laya.ui.IItem');
Laya.interface('laya.ui.ISelect');
Laya.interface('laya.ui.IRender');
Laya.interface('laya.runtime.IMarket');
Laya.interface('laya.filters.IFilter');
Laya.interface('laya.resource.IDispose');
Laya.interface('laya.runtime.ICPlatformClass');
//class Laya
var ___Laya=(function(){
	//function Laya(){}
	/**
	*表示是否捕获全局错误并弹出提示。默认为false。
	*适用于移动设备等不方便调试的时候，设置为true后，如有未知错误，可以弹窗抛出详细错误堆栈。
	*/
	__getset(1,Laya,'alertGlobalError',null,function(value){
		var erralert=0;
		if (value){
			Browser.window.onerror=function (msg,url,line,column,detail){
				if (erralert++< 5 && detail)
					alert("出错啦，请把此信息截图给研发商\n"+msg+"\n"+detail.stack);
			}
			}else {
			Browser.window.onerror=null;
		}
	});

	Laya.init=function(width,height,__plugins){
		var plugins=[];for(var i=2,sz=arguments.length;i<sz;i++)plugins.push(arguments[i]);
		if (Laya._isinit)return;
		Laya._isinit=true;
		ArrayBuffer.prototype.slice || (ArrayBuffer.prototype.slice=Laya._arrayBufferSlice);
		Browser.__init__();
		if (!Render.isConchApp){
			Context.__init__();
		}
		Laya.systemTimer=new Timer(false);
		Laya.startTimer=new Timer(false);
		Laya.physicsTimer=new Timer(false);
		Laya.updateTimer=new Timer(false);
		Laya.lateTimer=new Timer(false);
		Laya.timer=new Timer(false);
		Laya.loader=new LoaderManager();
		WeakObject.__init__();
		var isWebGLEnabled=false;
		for (var i=0,n=plugins.length;i < n;i++){
			if (plugins[i] && plugins[i].enable){
				plugins[i].enable();
				if (typeof plugins[i]==="WebGL")isWebGLEnabled=true;
			}
		}
		if (Render.isConchApp){
			if (!isWebGLEnabled)laya.webgl.WebGL.enable();
			RunDriver.enableNative();
		}
		ResourceManager.__init__();
		CacheManger.beginCheck();
		Laya._currentStage=Laya.stage=new Stage();
		Laya._getUrlPath();
		Laya.render=new Render(0,0);
		Laya.stage.size(width,height);
		window.stage=Laya.stage;
		RenderSprite.__init__();
		KeyBoardManager.__init__();
		MouseManager.instance.__init__(Laya.stage,Render.canvas);
		Input.__init__();
		SoundManager.autoStopMusic=true;
		return Render.canvas;
	}

	Laya._getUrlPath=function(){
		var location=Browser.window.location;
		var pathName=location.pathname;
		pathName=pathName.charAt(2)==':' ? pathName.substring(1):pathName;
		URL.rootPath=URL.basePath=URL.getPath(location.protocol=="file:" ? pathName :location.protocol+"//"+location.host+location.pathname);
	}

	Laya._arrayBufferSlice=function(start,end){
		var arr=this;
		var arrU8List=new Uint8Array(arr,start,end-start);
		var newU8List=new Uint8Array(arrU8List.length);
		newU8List.set(arrU8List);
		return newU8List.buffer;
	}

	Laya._runScript=function(script){
		return Browser.window[Laya._evcode](script);
	}

	Laya.enableDebugPanel=function(debugJsPath){
		(debugJsPath===void 0)&& (debugJsPath="libs/laya.debugtool.js");
		if (!Laya["DebugPanel"]){
			var script=Browser.createElement("script");
			script.onload=function (){
				Laya["DebugPanel"].enable();
			}
			script.src=debugJsPath;
			Browser.document.body.appendChild(script);
			}else {
			Laya["DebugPanel"].enable();
		}
	}

	Laya.stage=null;
	Laya.systemTimer=null;
	Laya.startTimer=null;
	Laya.physicsTimer=null;
	Laya.updateTimer=null;
	Laya.lateTimer=null;
	Laya.timer=null;
	Laya.loader=null;
	Laya.version="2.0.0beta3";
	Laya.render=null;
	Laya._currentStage=null;
	Laya._isinit=false;
	__static(Laya,
	['conchMarket',function(){return this.conchMarket=window.conch?conchMarket:null;},'PlatformClass',function(){return this.PlatformClass=window.PlatformClass;},'_evcode',function(){return this._evcode="eva"+"l";}
	]);
	return Laya;
})()


//class GameConfig
var GameConfig=(function(){
	function GameConfig(){}
	__class(GameConfig,'GameConfig');
	GameConfig.init=function(){
		var reg=ClassUtils.regClass;
	}

	GameConfig.height=1136;
	GameConfig.scaleMode="fixedwidth";
	GameConfig.screenMode="none";
	GameConfig.alignV="top";
	GameConfig.alignH="left";
	GameConfig.startScene=null;
	GameConfig.sceneRoot="";
	GameConfig.debug=false;
	GameConfig.stat=false;
	GameConfig.physicsDebug=false;
	GameConfig.exportSceneToJson=true;
	__static(GameConfig,
	['width',function(){return this.width=640
		;}
	]);
	GameConfig.__init$=function(){
		GameConfig.init();
	}

	return GameConfig;
})()


//class Main
var Main=(function(){
	function Main(){
		MiniAdpter.S_SON=true;
		if (window["Laya3D"])window["Laya3D"].init(GameConfig.width,GameConfig.height);
		else Laya.init(GameConfig.width,GameConfig.height,Laya["WebGL"]);
		Laya["Physics"] && Laya["Physics"].enable();
		Laya["DebugPanel"] && Laya["DebugPanel"].enable();
		Laya.stage.scaleMode=GameConfig.scaleMode;
		Laya.stage.screenMode=GameConfig.screenMode;
		Laya.stage.alignV=GameConfig.alignV;
		Laya.stage.alignH=GameConfig.alignH;
		URL.exportSceneToJson=GameConfig.exportSceneToJson;
		if (GameConfig.debug || Utils.getQueryString("debug")=="true")Laya.enableDebugPanel();
		if (GameConfig.physicsDebug && Laya["PhysicsDebugDraw"])Laya["PhysicsDebugDraw"].enable();
		if (GameConfig.stat)Stat.show();
		Laya.alertGlobalError=true;
		ResourceVersion.enable("version.json",Handler.create(this,this.onVersionLoaded),2);
	}

	__class(Main,'Main');
	var __proto=Main.prototype;
	__proto.onVersionLoaded=function(){
		AtlasInfoManager.enable("fileconfig.json",Handler.create(this,this.onConfigLoaded));
	}

	__proto.onConfigLoaded=function(){
		GameConfig.startScene && Scene.open(GameConfig.startScene);
		var sp=new Sprite();
		sp.graphics.drawRect(0,0,200,200,'#ff0000');
		Laya.stage.addChild(sp);
		if (Browser.onWeiXin){
			Browser.window.wx.onMessage(function(data){
				console.log("我是子域 接收到主域来的消息 "+data);
			});
			}else {
			console.log("not weiXin");
		}
	}

	return Main;
})()


//class Config
var Config=(function(){
	function Config(){}
	__class(Config,'Config');
	Config.animationInterval=50;
	Config.isAntialias=false;
	Config.isAlpha=false;
	Config.premultipliedAlpha=true;
	Config.isStencil=true;
	Config.preserveDrawingBuffer=false;
	Config.webGL2D_MeshAllocMaxMem=true;
	Config.is2DPixelArtGame=false;
	Config.useWebGL2=false;
	return Config;
})()


//class laya.events.EventDispatcher
var EventDispatcher=(function(){
	var EventHandler;
	function EventDispatcher(){
		/**@private */
		this._$0__events=null;
	}

	__class(EventDispatcher,'laya.events.EventDispatcher');
	var __proto=EventDispatcher.prototype;
	/**
	*检查 EventDispatcher 对象是否为特定事件类型注册了任何侦听器。
	*@param type 事件的类型。
	*@return 如果指定类型的侦听器已注册，则值为 true；否则，值为 false。
	*/
	__proto.hasListener=function(type){
		var listener=this._$0__events && this._$0__events[type];
		return !!listener;
	}

	/**
	*派发事件。
	*@param type 事件类型。
	*@param data （可选）回调数据。<b>注意：</b>如果是需要传递多个参数 p1,p2,p3,...可以使用数组结构如：[p1,p2,p3,...] ；如果需要回调单个参数 p ，且 p 是一个数组，则需要使用结构如：[p]，其他的单个参数 p ，可以直接传入参数 p。
	*@return 此事件类型是否有侦听者，如果有侦听者则值为 true，否则值为 false。
	*/
	__proto.event=function(type,data){
		if (!this._$0__events || !this._$0__events[type])return false;
		var listeners=this._$0__events[type];
		if (listeners.run){
			if (listeners.once)delete this._$0__events[type];
			data !=null ? listeners.runWith(data):listeners.run();
			}else {
			for (var i=0,n=listeners.length;i < n;i++){
				var listener=listeners[i];
				if (listener){
					(data !=null)? listener.runWith(data):listener.run();
				}
				if (!listener || listener.once){
					listeners.splice(i,1);
					i--;
					n--;
				}
			}
			if (listeners.length===0 && this._$0__events)delete this._$0__events[type];
		}
		return true;
	}

	/**
	*使用 EventDispatcher 对象注册指定类型的事件侦听器对象，以使侦听器能够接收事件通知。
	*@param type 事件的类型。
	*@param caller 事件侦听函数的执行域。
	*@param listener 事件侦听函数。
	*@param args （可选）事件侦听函数的回调参数。
	*@return 此 EventDispatcher 对象。
	*/
	__proto.on=function(type,caller,listener,args){
		return this._createListener(type,caller,listener,args,false);
	}

	/**
	*使用 EventDispatcher 对象注册指定类型的事件侦听器对象，以使侦听器能够接收事件通知，此侦听事件响应一次后自动移除。
	*@param type 事件的类型。
	*@param caller 事件侦听函数的执行域。
	*@param listener 事件侦听函数。
	*@param args （可选）事件侦听函数的回调参数。
	*@return 此 EventDispatcher 对象。
	*/
	__proto.once=function(type,caller,listener,args){
		return this._createListener(type,caller,listener,args,true);
	}

	/**@private */
	__proto._createListener=function(type,caller,listener,args,once,offBefore){
		(offBefore===void 0)&& (offBefore=true);
		offBefore && this.off(type,caller,listener,once);
		var handler=EventHandler.create(caller || this,listener,args,once);
		this._$0__events || (this._$0__events={});
		var events=this._$0__events;
		if (!events[type])events[type]=handler;
		else {
			if (!events[type].run)events[type].push(handler);
			else events[type]=[events[type],handler];
		}
		return this;
	}

	/**
	*从 EventDispatcher 对象中删除侦听器。
	*@param type 事件的类型。
	*@param caller 事件侦听函数的执行域。
	*@param listener 事件侦听函数。
	*@param onceOnly （可选）如果值为 true ,则只移除通过 once 方法添加的侦听器。
	*@return 此 EventDispatcher 对象。
	*/
	__proto.off=function(type,caller,listener,onceOnly){
		(onceOnly===void 0)&& (onceOnly=false);
		if (!this._$0__events || !this._$0__events[type])return this;
		var listeners=this._$0__events[type];
		if (listener !=null){
			if (listeners.run){
				if ((!caller || listeners.caller===caller)&& (listener==null || listeners.method===listener)&& (!onceOnly || listeners.once)){
					delete this._$0__events[type];
					listeners.recover();
				}
				}else {
				var count=0;
				for (var i=0,n=listeners.length;i < n;i++){
					var item=listeners[i];
					if (!item){
						count++;
						continue ;
					}
					if (item && (!caller || item.caller===caller)&& (listener==null || item.method===listener)&& (!onceOnly || item.once)){
						count++;
						listeners[i]=null;
						item.recover();
					}
				}
				if (count===n)delete this._$0__events[type];
			}
		}
		return this;
	}

	/**
	*从 EventDispatcher 对象中删除指定事件类型的所有侦听器。
	*@param type （可选）事件类型，如果值为 null，则移除本对象所有类型的侦听器。
	*@return 此 EventDispatcher 对象。
	*/
	__proto.offAll=function(type){
		var events=this._$0__events;
		if (!events)return this;
		if (type){
			this._recoverHandlers(events[type]);
			delete events[type];
			}else {
			for (var name in events){
				this._recoverHandlers(events[name]);
			}
			this._$0__events=null;
		}
		return this;
	}

	/**
	*移除caller为target的所有事件监听
	*@param caller caller对象
	*/
	__proto.offAllCaller=function(caller){
		if (caller && this._$0__events){
			for (var name in this._$0__events){
				this.off(name,caller,null);
			}
		}
		return this;
	}

	__proto._recoverHandlers=function(arr){
		if (!arr)return;
		if (arr.run){
			arr.recover();
			}else {
			for (var i=arr.length-1;i >-1;i--){
				if (arr[i]){
					arr[i].recover();
					arr[i]=null;
				}
			}
		}
	}

	/**
	*检测指定事件类型是否是鼠标事件。
	*@param type 事件的类型。
	*@return 如果是鼠标事件，则值为 true;否则，值为 false。
	*/
	__proto.isMouseEvent=function(type){
		return EventDispatcher.MOUSE_EVENTS[type] || false;
	}

	EventDispatcher.MOUSE_EVENTS={"rightmousedown":true,"rightmouseup":true,"rightclick":true,"mousedown":true,"mouseup":true,"mousemove":true,"mouseover":true,"mouseout":true,"click":true,"doubleclick":true};
	EventDispatcher.__init$=function(){
		Object.defineProperty(laya.events.EventDispatcher.prototype,"_events",{enumerable:false,writable:true});
		/**@private */
		//class EventHandler extends laya.utils.Handler
		EventHandler=(function(_super){
			function EventHandler(caller,method,args,once){
				EventHandler.__super.call(this,caller,method,args,once);
			}
			__class(EventHandler,'',_super);
			var __proto=EventHandler.prototype;
			__proto.recover=function(){
				if (this._id > 0){
					this._id=0;
					EventHandler._pool.push(this.clear());
				}
			}
			EventHandler.create=function(caller,method,args,once){
				(once===void 0)&& (once=true);
				if (EventHandler._pool.length)return EventHandler._pool.pop().setTo(caller,method,args,once);
				return new EventHandler(caller,method,args,once);
			}
			EventHandler._pool=[];
			return EventHandler;
		})(Handler)
	}

	return EventDispatcher;
})()


//class laya.display.Graphics
var Graphics=(function(){
	function Graphics(){
		/**@private */
		//this._sp=null;
		/**@private */
		this._one=null;
		/**@private */
		this._cmds=null;
		/**@private */
		//this._vectorgraphArray=null;
		/**@private */
		//this._graphicBounds=null;
		/**@private */
		this.autoDestroy=false;
		this._render=this._renderEmpty;
		this._createData();
	}

	__class(Graphics,'laya.display.Graphics');
	var __proto=Graphics.prototype;
	/**@private */
	__proto._createData=function(){}
	/**@private */
	__proto._clearData=function(){}
	/**@private */
	__proto._destroyData=function(){}
	/**
	*<p>销毁此对象。</p>
	*/
	__proto.destroy=function(){
		this.clear(true);
		if (this._graphicBounds)this._graphicBounds.destroy();
		this._graphicBounds=null;
		this._vectorgraphArray=null;
		if (this._sp){
			this._sp._renderType=0;
			this._sp._setRenderType(0);
			this._sp=null;
		}
		this._destroyData();
	}

	/**
	*<p>清空绘制命令。</p>
	*@param recoverCmds 是否回收绘图指令数组，设置为true，则对指令数组进行回收以节省内存开销，建议设置为true进行回收，但如果手动引用了数组，不建议回收
	*/
	__proto.clear=function(recoverCmds){
		(recoverCmds===void 0)&& (recoverCmds=true);
		if (recoverCmds){
			var tCmd=this._one;
			if (this._cmds){
				var i=0,len=this._cmds.length;
				for (i=0;i < len;i++){
					tCmd=this._cmds[i];
					tCmd.recover();
				}
				this._cmds.length=0;
				}else if (tCmd){
				tCmd.recover();
			}
			}else {
			this._cmds=null;
		}
		this._one=null;
		this._render=this._renderEmpty;
		this._clearData();
		if (this._sp){
			this._sp._renderType &=~0x200;
			this._sp._setRenderType(this._sp._renderType);
		}
		this._repaint();
		if (this._vectorgraphArray){
			for (i=0,len=this._vectorgraphArray.length;i < len;i++){
				VectorGraphManager.getInstance().deleteShape(this._vectorgraphArray[i]);
			}
			this._vectorgraphArray.length=0;
		}
	}

	/**@private */
	__proto._clearBoundsCache=function(){
		if (this._graphicBounds)this._graphicBounds.reset();
	}

	/**@private */
	__proto._initGraphicBounds=function(){
		if (!this._graphicBounds){
			this._graphicBounds=GraphicsBounds.create();
			this._graphicBounds._graphics=this;
		}
	}

	/**
	*@private
	*重绘此对象。
	*/
	__proto._repaint=function(){
		this._clearBoundsCache();
		this._sp && this._sp.repaint();
	}

	//TODO:coverage
	__proto._isOnlyOne=function(){
		return !this._cmds || this._cmds.length===0;
	}

	/**
	*获取位置及宽高信息矩阵(比较耗CPU，频繁使用会造成卡顿，尽量少用)。
	*@param realSize （可选）使用图片的真实大小，默认为false
	*@return 位置与宽高组成的 一个 Rectangle 对象。
	*/
	__proto.getBounds=function(realSize){
		(realSize===void 0)&& (realSize=false);
		this._initGraphicBounds();
		return this._graphicBounds.getBounds(realSize);
	}

	/**
	*@private
	*@param realSize （可选）使用图片的真实大小，默认为false
	*获取端点列表。
	*/
	__proto.getBoundPoints=function(realSize){
		(realSize===void 0)&& (realSize=false);
		this._initGraphicBounds();
		return this._graphicBounds.getBoundPoints(realSize);
	}

	/**
	*绘制单独图片
	*@param texture 纹理。
	*@param x （可选）X轴偏移量。
	*@param y （可选）Y轴偏移量。
	*@param width （可选）宽度。
	*@param height （可选）高度。
	*/
	__proto.drawImage=function(texture,x,y,width,height){
		(x===void 0)&& (x=0);
		(y===void 0)&& (y=0);
		(width===void 0)&& (width=0);
		(height===void 0)&& (height=0);
		if (!texture)return null;
		if (!width)width=texture.sourceWidth;
		if (!height)height=texture.sourceHeight;
		if (texture.getIsReady()){
			var wRate=width / texture.sourceWidth;
			var hRate=height / texture.sourceHeight;
			width=texture.width *wRate;
			height=texture.height *hRate;
			if (width <=0 || height <=0)return null;
			x+=texture.offsetX *wRate;
			y+=texture.offsetY *hRate;
		}
		if (this._sp){
			this._sp._renderType |=0x200;
			this._sp._setRenderType(this._sp._renderType);
		};
		var args=DrawImageCmd.create.call(this,texture,x,y,width,height);
		if (this._one==null){
			this._one=args;
			this._render=this._renderOneImg;
			}else {
			this._saveToCmd(null,args);
		}
		this._repaint();
		return args;
	}

	/**
	*绘制纹理，相比drawImage功能更强大，性能会差一些
	*@param texture 纹理。
	*@param x （可选）X轴偏移量。
	*@param y （可选）Y轴偏移量。
	*@param width （可选）宽度。
	*@param height （可选）高度。
	*@param matrix （可选）矩阵信息。
	*@param alpha （可选）透明度。
	*@param color （可选）颜色滤镜。
	*@param blendMode （可选）混合模式。
	*/
	__proto.drawTexture=function(texture,x,y,width,height,matrix,alpha,color,blendMode){
		(x===void 0)&& (x=0);
		(y===void 0)&& (y=0);
		(width===void 0)&& (width=0);
		(height===void 0)&& (height=0);
		(alpha===void 0)&& (alpha=1);
		if (!texture || alpha < 0.01)return null;
		if (!texture.getIsReady())return null;
		if (!width)width=texture.sourceWidth;
		if (!height)height=texture.sourceHeight;
		if (texture.getIsReady()){
			var offset=(!Render.isWebGL && (Browser.onFirefox || Browser.onEdge || Browser.onIE || Browser.onSafari))? 0.5 :0;
			var wRate=width / texture.sourceWidth;
			var hRate=height / texture.sourceHeight;
			width=texture.width *wRate;
			height=texture.height *hRate;
			if (width <=0 || height <=0)return null;
			x+=texture.offsetX *wRate;
			y+=texture.offsetY *hRate;
			x-=offset;
			y-=offset;
			width+=2 *offset;
			height+=2 *offset;
		}
		if (this._sp){
			this._sp._renderType |=0x200;
			this._sp._setRenderType(this._sp._renderType);
		}
		if (!Render.isConchApp && !Render.isWebGL && (blendMode || color)){
			var canvas=new HTMLCanvas();
			canvas.size(width,height);
			var ctx=canvas.getContext('2d');
			ctx.drawTexture(texture,0,0,width,height);
			texture=new Texture(canvas);
			if (color){
				var filter=new ColorFilterAction();
				var colorArr=ColorUtils.create(color).arrColor;
				filter.data=new ColorFilter().color(colorArr[0] *255,colorArr[1] *255,colorArr[2] *255);
				filter.apply({ctx:{ctx:ctx}});
			}
		};
		var args=DrawTextureCmd.create.call(this,texture,x,y,width,height,matrix,alpha,color,blendMode);
		this._repaint();
		return this._saveToCmd(null,args);
	}

	/**
	*批量绘制同样纹理。
	*@param texture 纹理。
	*@param pos 绘制次数和坐标。
	*/
	__proto.drawTextures=function(texture,pos){
		if (!texture)return null;
		return this._saveToCmd(Render._context._drawTextures,DrawTexturesCmd.create.call(this,texture,pos));
	}

	/**
	*绘制一组三角形
	*@param texture 纹理。
	*@param x X轴偏移量。
	*@param y Y轴偏移量。
	*@param vertices 顶点数组。
	*@param indices 顶点索引。
	*@param uvData UV数据。
	*@param matrix 缩放矩阵。
	*@param alpha alpha
	*@param color 颜色变换
	*@param blendMode blend模式
	*/
	__proto.drawTriangles=function(texture,x,y,vertices,uvs,indices,matrix,alpha,color,blendMode){
		(alpha===void 0)&& (alpha=1);
		return this._saveToCmd(Render._context.drawTriangles,DrawTrianglesCmd.create.call(this,texture,x,y,vertices,uvs,indices,matrix,alpha,color,blendMode));
	}

	/**
	*用texture填充。
	*@param texture 纹理。
	*@param x X轴偏移量。
	*@param y Y轴偏移量。
	*@param width （可选）宽度。
	*@param height （可选）高度。
	*@param type （可选）填充类型 repeat|repeat-x|repeat-y|no-repeat
	*@param offset （可选）贴图纹理偏移
	*
	*/
	__proto.fillTexture=function(texture,x,y,width,height,type,offset){
		(width===void 0)&& (width=0);
		(height===void 0)&& (height=0);
		(type===void 0)&& (type="repeat");
		if (texture && texture.getIsReady())
			return this._saveToCmd(Render._context._fillTexture,FillTextureCmd.create.call(this,texture,x,y,width,height,type,offset || Point.EMPTY,{}));
		else
		return null;
	}

	/**
	*@private
	*保存到命令流。
	*/
	__proto._saveToCmd=function(fun,args){
		if (this._sp){
			this._sp._renderType |=0x200;
			this._sp._setRenderType(this._sp._renderType);
		}
		if (this._one==null){
			this._one=args;
			this._render=this._renderOne;
			}else {
			this._render=this._renderAll;
			(this._cmds || (this._cmds=[])).length===0 && this._cmds.push(this._one);
			this._cmds.push(args);
		}
		this._repaint();
		return args;
	}

	/**
	*设置剪裁区域，超出剪裁区域的坐标不显示。
	*@param x X 轴偏移量。
	*@param y Y 轴偏移量。
	*@param width 宽度。
	*@param height 高度。
	*/
	__proto.clipRect=function(x,y,width,height){
		return this._saveToCmd(Render._context._clipRect,ClipRectCmd.create.call(this,x,y,width,height));
	}

	/**
	*在画布上绘制文本。
	*@param text 在画布上输出的文本。
	*@param x 开始绘制文本的 x 坐标位置（相对于画布）。
	*@param y 开始绘制文本的 y 坐标位置（相对于画布）。
	*@param font 定义字号和字体，比如"20px Arial"。
	*@param color 定义文本颜色，比如"#ff0000"。
	*@param textAlign 文本对齐方式，可选值："left"，"center"，"right"。
	*/
	__proto.fillText=function(text,x,y,font,color,textAlign){
		return this._saveToCmd(Render._context._fillText,FillTextCmd.create.call(this,text,x,y,font || Text.defaultFontStr(),color,textAlign));
	}

	/**
	*在画布上绘制“被填充且镶边的”文本。
	*@param text 在画布上输出的文本。
	*@param x 开始绘制文本的 x 坐标位置（相对于画布）。
	*@param y 开始绘制文本的 y 坐标位置（相对于画布）。
	*@param font 定义字体和字号，比如"20px Arial"。
	*@param fillColor 定义文本颜色，比如"#ff0000"。
	*@param borderColor 定义镶边文本颜色。
	*@param lineWidth 镶边线条宽度。
	*@param textAlign 文本对齐方式，可选值："left"，"center"，"right"。
	*/
	__proto.fillBorderText=function(text,x,y,font,fillColor,borderColor,lineWidth,textAlign){
		return this._saveToCmd(Render._context._fillBorderText,FillBorderTextCmd.create.call(this,text,x,y,font || Text.defaultFontStr(),fillColor,borderColor,lineWidth,textAlign));
	}

	/***@private */
	__proto.fillWords=function(words,x,y,font,color){
		return this._saveToCmd(Render._context._fillWords,FillWordsCmd.create.call(this,words,x,y,font || Text.defaultFontStr(),color));
	}

	/***@private */
	__proto.fillBorderWords=function(words,x,y,font,fillColor,borderColor,lineWidth){
		return this._saveToCmd(Render._context._fillBorderWords,FillBorderWordsCmd.create.call(this,words,x,y,font || Text.defaultFontStr(),fillColor,borderColor,lineWidth));
	}

	/**
	*在画布上绘制文本（没有填色）。文本的默认颜色是黑色。
	*@param text 在画布上输出的文本。
	*@param x 开始绘制文本的 x 坐标位置（相对于画布）。
	*@param y 开始绘制文本的 y 坐标位置（相对于画布）。
	*@param font 定义字体和字号，比如"20px Arial"。
	*@param color 定义文本颜色，比如"#ff0000"。
	*@param lineWidth 线条宽度。
	*@param textAlign 文本对齐方式，可选值："left"，"center"，"right"。
	*/
	__proto.strokeText=function(text,x,y,font,color,lineWidth,textAlign){
		return this._saveToCmd(Render._context._strokeText,StrokeTextCmd.create.call(this,text,x,y,font || Text.defaultFontStr(),color,lineWidth,textAlign));
	}

	/**
	*设置透明度。
	*@param value 透明度。
	*/
	__proto.alpha=function(alpha){
		return this._saveToCmd(Render._context._alpha,AlphaCmd.create.call(this,alpha));
	}

	/**
	*替换绘图的当前转换矩阵。
	*@param mat 矩阵。
	*@param pivotX （可选）水平方向轴心点坐标。
	*@param pivotY （可选）垂直方向轴心点坐标。
	*/
	__proto.transform=function(matrix,pivotX,pivotY){
		(pivotX===void 0)&& (pivotX=0);
		(pivotY===void 0)&& (pivotY=0);
		return this._saveToCmd(Render._context._transform,TransformCmd.create.call(this,matrix,pivotX,pivotY));
	}

	/**
	*旋转当前绘图。(推荐使用transform，性能更高)
	*@param angle 旋转角度，以弧度计。
	*@param pivotX （可选）水平方向轴心点坐标。
	*@param pivotY （可选）垂直方向轴心点坐标。
	*/
	__proto.rotate=function(angle,pivotX,pivotY){
		(pivotX===void 0)&& (pivotX=0);
		(pivotY===void 0)&& (pivotY=0);
		return this._saveToCmd(Render._context._rotate,RotateCmd.create.call(this,angle,pivotX,pivotY));
	}

	/**
	*缩放当前绘图至更大或更小。(推荐使用transform，性能更高)
	*@param scaleX 水平方向缩放值。
	*@param scaleY 垂直方向缩放值。
	*@param pivotX （可选）水平方向轴心点坐标。
	*@param pivotY （可选）垂直方向轴心点坐标。
	*/
	__proto.scale=function(scaleX,scaleY,pivotX,pivotY){
		(pivotX===void 0)&& (pivotX=0);
		(pivotY===void 0)&& (pivotY=0);
		return this._saveToCmd(Render._context._scale,ScaleCmd.create.call(this,scaleX,scaleY,pivotX,pivotY));
	}

	/**
	*重新映射画布上的 (0,0)位置。
	*@param x 添加到水平坐标（x）上的值。
	*@param y 添加到垂直坐标（y）上的值。
	*/
	__proto.translate=function(tx,ty){
		return this._saveToCmd(Render._context._translate,TranslateCmd.create.call(this,tx,ty));
	}

	/**
	*保存当前环境的状态。
	*/
	__proto.save=function(){
		return this._saveToCmd(Render._context._save,SaveCmd.create.call(this));
	}

	/**
	*返回之前保存过的路径状态和属性。
	*/
	__proto.restore=function(){
		return this._saveToCmd(Render._context._restore,RestoreCmd.create.call(this));
	}

	/**
	*@private
	*替换文本内容。
	*@param text 文本内容。
	*@return 替换成功则值为true，否则值为flase。
	*/
	__proto.replaceText=function(text){
		this._repaint();
		var cmds=this._cmds;
		if (!cmds){
			if (this._one && this._isTextCmd(this._one)){
				this._one.text=text;
				return true;
			}
			}else {
			for (var i=cmds.length-1;i >-1;i--){
				if (this._isTextCmd(cmds[i])){
					cmds[i].text=text;
					return true;
				}
			}
		}
		return false;
	}

	/**@private */
	__proto._isTextCmd=function(cmd){
		var cmdID=cmd.cmdID;
		return cmdID=="FillText" || cmdID=="StrokeText" || cmdID=="FillBorderText";
	}

	/**
	*@private
	*替换文本颜色。
	*@param color 颜色。
	*/
	__proto.replaceTextColor=function(color){
		this._repaint();
		var cmds=this._cmds;
		if (!cmds){
			if (this._one && this._isTextCmd(this._one)){
				this._setTextCmdColor(this._one,color);
			}
			}else {
			for (var i=cmds.length-1;i >-1;i--){
				if (this._isTextCmd(cmds[i])){
					this._setTextCmdColor(cmds[i],color);
				}
			}
		}
	}

	/**@private */
	__proto._setTextCmdColor=function(cmdO,color){
		var cmdID=cmdO.cmdID;
		switch (cmdID){
			case "FillText":
			case "StrokeText":
				cmdO.color=color;
				break ;
			case "FillBorderText":
			case "FillBorderWords":
			case "FillBorderText":
				cmdO.fillColor=color;
				break ;
			}
	}

	/**
	*加载并显示一个图片。
	*@param url 图片地址。
	*@param x （可选）显示图片的x位置。
	*@param y （可选）显示图片的y位置。
	*@param width （可选）显示图片的宽度，设置为0表示使用图片默认宽度。
	*@param height （可选）显示图片的高度，设置为0表示使用图片默认高度。
	*@param complete （可选）加载完成回调。
	*/
	__proto.loadImage=function(url,x,y,width,height,complete){
		(x===void 0)&& (x=0);
		(y===void 0)&& (y=0);
		(width===void 0)&& (width=0);
		(height===void 0)&& (height=0);
		var tex=Loader.getRes(url);
		if (!tex){
			tex=new Texture();
			tex.load(url);
			Loader.cacheRes(url,tex);
			tex.once("ready",this,this.drawImage,[tex,x,y,width,height]);
			}else {
			if (!tex.getIsReady()){
				tex.once("ready",this,this.drawImage,[tex,x,y,width,height]);
			}else
			this.drawImage(tex,x,y,width,height);
		}
		if (complete !=null){
			tex.getIsReady()? complete.call(this._sp):tex.on("ready",this._sp,complete);
		}
	}

	/**
	*@private
	*/
	__proto._renderEmpty=function(sprite,context,x,y){}
	/**
	*@private
	*/
	__proto._renderAll=function(sprite,context,x,y){
		var cmds=this._cmds,cmd;
		for (var i=0,n=cmds.length;i < n;i++){
			(cmd=cmds[i]).run(context,x,y);
		}
	}

	/**
	*@private
	*/
	__proto._renderOne=function(sprite,context,x,y){
		this._one.run(context,x,y);
	}

	/**
	*@private
	*/
	__proto._renderOneImg=function(sprite,context,x,y){
		this._one.run(context,x,y);
	}

	/**
	*绘制一条线。
	*@param fromX X轴开始位置。
	*@param fromY Y轴开始位置。
	*@param toX X轴结束位置。
	*@param toY Y轴结束位置。
	*@param lineColor 颜色。
	*@param lineWidth （可选）线条宽度。
	*/
	__proto.drawLine=function(fromX,fromY,toX,toY,lineColor,lineWidth){
		(lineWidth===void 0)&& (lineWidth=1);
		var tId=0;
		if (Render.isWebGL){
			tId=VectorGraphManager.getInstance().getId();
			if (this._vectorgraphArray==null)this._vectorgraphArray=[];
			this._vectorgraphArray.push(tId);
		};
		var offset=(lineWidth < 1 || lineWidth % 2===0)? 0 :0.5;
		return this._saveToCmd(Render._context._drawLine,DrawLineCmd.create.call(this,fromX+offset,fromY+offset,toX+offset,toY+offset,lineColor,lineWidth,tId));
	}

	/**
	*绘制一系列线段。
	*@param x 开始绘制的X轴位置。
	*@param y 开始绘制的Y轴位置。
	*@param points 线段的点集合。格式:[x1,y1,x2,y2,x3,y3...]。
	*@param lineColor 线段颜色，或者填充绘图的渐变对象。
	*@param lineWidth （可选）线段宽度。
	*/
	__proto.drawLines=function(x,y,points,lineColor,lineWidth){
		(lineWidth===void 0)&& (lineWidth=1);
		var tId=0;
		if (!points || points.length < 4)return null;
		if (Render.isWebGL){
			tId=VectorGraphManager.getInstance().getId();
			if (this._vectorgraphArray==null)this._vectorgraphArray=[];
			this._vectorgraphArray.push(tId);
		};
		var offset=(lineWidth < 1 || lineWidth % 2===0)? 0 :0.5;
		return this._saveToCmd(Render._context._drawLines,DrawLinesCmd.create.call(this,x+offset,y+offset,points,lineColor,lineWidth,tId));
	}

	/**
	*绘制一系列曲线。
	*@param x 开始绘制的 X 轴位置。
	*@param y 开始绘制的 Y 轴位置。
	*@param points 线段的点集合，格式[controlX,controlY,anchorX,anchorY...]。
	*@param lineColor 线段颜色，或者填充绘图的渐变对象。
	*@param lineWidth （可选）线段宽度。
	*/
	__proto.drawCurves=function(x,y,points,lineColor,lineWidth){
		(lineWidth===void 0)&& (lineWidth=1);
		return this._saveToCmd(Render._context._drawCurves,DrawCurvesCmd.create.call(this,x,y,points,lineColor,lineWidth));
	}

	/**
	*绘制矩形。
	*@param x 开始绘制的 X 轴位置。
	*@param y 开始绘制的 Y 轴位置。
	*@param width 矩形宽度。
	*@param height 矩形高度。
	*@param fillColor 填充颜色，或者填充绘图的渐变对象。
	*@param lineColor （可选）边框颜色，或者填充绘图的渐变对象。
	*@param lineWidth （可选）边框宽度。
	*/
	__proto.drawRect=function(x,y,width,height,fillColor,lineColor,lineWidth){
		(lineWidth===void 0)&& (lineWidth=1);
		var offset=(lineWidth >=1 && lineColor)? lineWidth / 2 :0;
		var lineOffset=lineColor ? lineWidth :0;
		return this._saveToCmd(Render._context.drawRect,DrawRectCmd.create.call(this,x+offset,y+offset,width-lineOffset,height-lineOffset,fillColor,lineColor,lineWidth));
	}

	/**
	*绘制圆形。
	*@param x 圆点X 轴位置。
	*@param y 圆点Y 轴位置。
	*@param radius 半径。
	*@param fillColor 填充颜色，或者填充绘图的渐变对象。
	*@param lineColor （可选）边框颜色，或者填充绘图的渐变对象。
	*@param lineWidth （可选）边框宽度。
	*/
	__proto.drawCircle=function(x,y,radius,fillColor,lineColor,lineWidth){
		(lineWidth===void 0)&& (lineWidth=1);
		var offset=(lineWidth >=1 && lineColor)? lineWidth / 2 :0;
		var tId=0;
		if (Render.isWebGL){
			tId=VectorGraphManager.getInstance().getId();
			if (this._vectorgraphArray==null)this._vectorgraphArray=[];
			this._vectorgraphArray.push(tId);
		}
		return this._saveToCmd(Render._context._drawCircle,DrawCircleCmd.create.call(this,x,y,radius-offset,fillColor,lineColor,lineWidth,tId));
	}

	/**
	*绘制扇形。
	*@param x 开始绘制的 X 轴位置。
	*@param y 开始绘制的 Y 轴位置。
	*@param radius 扇形半径。
	*@param startAngle 开始角度。
	*@param endAngle 结束角度。
	*@param fillColor 填充颜色，或者填充绘图的渐变对象。
	*@param lineColor （可选）边框颜色，或者填充绘图的渐变对象。
	*@param lineWidth （可选）边框宽度。
	*/
	__proto.drawPie=function(x,y,radius,startAngle,endAngle,fillColor,lineColor,lineWidth){
		(lineWidth===void 0)&& (lineWidth=1);
		var offset=(lineWidth >=1 && lineColor)? lineWidth / 2 :0;
		var lineOffset=lineColor ? lineWidth :0;
		var tId=0;
		if (Render.isWebGL){
			tId=VectorGraphManager.getInstance().getId();
			if (this._vectorgraphArray==null)this._vectorgraphArray=[];
			this._vectorgraphArray.push(tId);
		}
		return this._saveToCmd(Render._context._drawPie,DrawPieCmd.create.call(this,x+offset,y+offset,radius-lineOffset,Utils.toRadian(startAngle),Utils.toRadian(endAngle),fillColor,lineColor,lineWidth,tId));
	}

	/**
	*绘制多边形。
	*@param x 开始绘制的 X 轴位置。
	*@param y 开始绘制的 Y 轴位置。
	*@param points 多边形的点集合。
	*@param fillColor 填充颜色，或者填充绘图的渐变对象。
	*@param lineColor （可选）边框颜色，或者填充绘图的渐变对象。
	*@param lineWidth （可选）边框宽度。
	*/
	__proto.drawPoly=function(x,y,points,fillColor,lineColor,lineWidth){
		(lineWidth===void 0)&& (lineWidth=1);
		var tId=0;
		if (Render.isWebGL){
			tId=VectorGraphManager.getInstance().getId();
			if (this._vectorgraphArray==null)this._vectorgraphArray=[];
			this._vectorgraphArray.push(tId);
			var tIsConvexPolygon=false;
			if (points.length > 6){
				tIsConvexPolygon=false;
				}else {
				tIsConvexPolygon=true;
			}
		};
		var offset=(lineWidth >=1 && lineColor)? (lineWidth % 2===0 ? 0 :0.5):0;
		return this._saveToCmd(Render._context._drawPoly,DrawPolyCmd.create.call(this,x+offset,y+offset,points,fillColor,lineColor,lineWidth,tIsConvexPolygon,tId));
	}

	/**
	*绘制路径。
	*@param x 开始绘制的 X 轴位置。
	*@param y 开始绘制的 Y 轴位置。
	*@param paths 路径集合，路径支持以下格式：[["moveTo",x,y],["lineTo",x,y],["arcTo",x1,y1,x2,y2,r],["closePath"]]。
	*@param brush （可选）刷子定义，支持以下设置{fillStyle:"#FF0000"}。
	*@param pen （可选）画笔定义，支持以下设置{strokeStyle,lineWidth,lineJoin:"bevel|round|miter",lineCap:"butt|round|square",miterLimit}。
	*/
	__proto.drawPath=function(x,y,paths,brush,pen){
		return this._saveToCmd(Render._context._drawPath,DrawPathCmd.create.call(this,x,y,paths,brush,pen));
	}

	/**
	*@private
	*命令流。存储了所有绘制命令。
	*/
	__getset(0,__proto,'cmds',function(){
		return this._cmds;
		},function(value){
		if (this._sp){
			this._sp._renderType |=0x200;
			this._sp._setRenderType(this._sp._renderType);
		}
		this._cmds=value;
		this._render=this._renderAll;
		this._repaint();
	});

	return Graphics;
})()


//class laya.components.Component
var Component=(function(){
	function Component(){
		/**@private [实现IListPool接口]*/
		//this._destroyed=false;
		/**@private [实现IListPool接口]*/
		//this._indexInList=0;
		/**@private */
		//this._id=0;
		/**@private */
		//this._enabled=false;
		/**@private */
		//this._active=false;
		/**@private */
		//this._awaked=false;
		/**
		*[只读]获取所属Node节点。
		*@readonly
		*/
		//this.owner=null;
		this._id=Utils.getGID();
		this._resetComp();
	}

	__class(Component,'laya.components.Component');
	var __proto=Component.prototype;
	Laya.imps(__proto,{"laya.resource.ISingletonElement":true,"laya.resource.IDestroy":true})
	/**
	*@private
	*/
	__proto._resetComp=function(){
		this._indexInList=-1;
		this._enabled=true;
		this._active=false;
		this._awaked=false;
		this.owner=null;
	}

	/**
	*[实现IListPool接口]
	*@private
	*/
	__proto._getIndexInList=function(){
		return this._indexInList;
	}

	/**
	*[实现IListPool接口]
	*@private
	*/
	__proto._setIndexInList=function(index){
		this._indexInList=index;
	}

	/**
	*被添加到节点后调用，可根据需要重写此方法
	*@private
	*/
	__proto._onAdded=function(){}
	/**
	*被激活后调用，可根据需要重写此方法
	*@private
	*/
	__proto._onAwake=function(){}
	/**
	*被激活后调用，可根据需要重写此方法
	*@private
	*/
	__proto._onEnable=function(){}
	/**
	*被禁用时调用，可根据需要重写此方法
	*@private
	*/
	__proto._onDisable=function(){}
	/**
	*被添加到Scene后调用，无论Scene是否在舞台上，可根据需要重写此方法
	*@private
	*/
	__proto._onEnableInScene=function(){}
	/**
	*从Scene移除后调用，无论Scene是否在舞台上，可根据需要重写此方法
	*@private
	*/
	__proto._onDisableInScene=function(){}
	/**
	*被销毁时调用，可根据需要重写此方法
	*@private
	*/
	__proto._onDestroy=function(){}
	/**
	*重置组件参数到默认值，如果实现了这个函数，则组件会被重置并且自动回收到对象池，方便下次复用
	*如果没有重置，则不进行回收复用
	*此方法为虚方法，使用时重写覆盖即可
	*/
	__proto.onReset=function(){}
	/**
	*@private
	*/
	__proto._parse=function(data){}
	/**
	*@private
	*/
	__proto._cloneTo=function(dest){}
	/**
	*@private
	*/
	__proto._setActive=function(value){
		if (this._active===value)return;
		if (!this.owner.activeInHierarchy)return;
		this._active=value;
		if (value){
			if (!this._awaked){
				this._awaked=true;
				this._onAwake();
			}
			this._enabled && this._onEnable();
			}else {
			this._enabled && this._onDisable();
		}
	}

	/**
	*@private
	*/
	__proto._setActiveInScene=function(value){
		if (value)this._onEnableInScene();
		else this._onDisableInScene();
	}

	/**
	*销毁组件
	*/
	__proto.destroy=function(){
		if (this.owner)this.owner._destroyComponent(this);
	}

	/**
	*@private
	*/
	__proto._destroy=function(){
		this._active && this._setActive(false);
		this.owner._scene && this._setActiveInScene(false);
		this._onDestroy();
		this._destroyed=true;
		if (this.onReset!==laya.components.Component.prototype.onReset){
			this.onReset();
			this._resetComp();
			Pool.recoverByClass(this);
			}else {
			this._resetComp();
		}
	}

	/**
	*获取唯一标识ID。
	*/
	__getset(0,__proto,'id',function(){
		return this._id;
	});

	/**
	*获取是否启用组件。
	*/
	__getset(0,__proto,'enabled',function(){
		return this._enabled;
		},function(value){
		this._enabled=value;
		if (this.owner){
			if (value)this.owner.activeInHierarchy && this._onEnable();
			else this._active && this._onDisable();
		}
	});

	/**
	*获取是否为单实例组件。
	*/
	__getset(0,__proto,'isSingleton',function(){
		return true;
	});

	/**
	*获取是否已经销毁 。
	*/
	__getset(0,__proto,'destroyed',function(){
		return this._destroyed;
	});

	return Component;
})()


//class laya.components.Prefab
var Prefab=(function(){
	function Prefab(){
		/**@private */
		this.json=null;
	}

	__class(Prefab,'laya.components.Prefab');
	var __proto=Prefab.prototype;
	/**
	*通过预制创建实例
	*/
	__proto.create=function(){
		if (this.json)return SceneUtils.createByData(null,this.json);
		return null;
	}

	return Prefab;
})()


//class laya.Const
var Const=(function(){
	function Const(){}
	__class(Const,'laya.Const');
	Const.NOT_ACTIVE=0x01;
	Const.ACTIVE_INHIERARCHY=0x02;
	Const.AWAKED=0x04;
	Const.NOT_READY=0x08;
	Const.DISPLAY=0x10;
	Const.HAS_ZORDER=0x20;
	Const.HAS_MOUSE=0x40;
	Const.DISPLAYED_INSTAGE=0x80;
	return Const;
})()


//class laya.display.BitmapFont
var BitmapFont=(function(){
	function BitmapFont(){
		this._texture=null;
		this._fontCharDic={};
		this._fontWidthMap={};
		this._complete=null;
		this._path=null;
		this._maxWidth=0;
		this._spaceWidth=10;
		this._padding=null;
		/**当前位图字体字号，使用时，如果字号和设置不同，并且autoScaleSize=true，则按照设置字号比率进行缩放显示。*/
		this.fontSize=12;
		/**表示是否根据实际使用的字体大小缩放位图字体大小。*/
		this.autoScaleSize=false;
		/**字符间距（以像素为单位）。*/
		this.letterSpacing=0;
	}

	__class(BitmapFont,'laya.display.BitmapFont');
	var __proto=BitmapFont.prototype;
	/**
	*通过指定位图字体文件路径，加载位图字体文件，加载完成后会自动解析。
	*@param path 位图字体文件的路径。
	*@param complete 加载并解析完成的回调。
	*/
	__proto.loadFont=function(path,complete){
		this._path=path;
		this._complete=complete;
		if (!path || path.indexOf(".fnt")===-1){
			console.error('Bitmap font configuration information must be a ".fnt" file');
			return;
		}
		Laya.loader.load([{url:path,type:"xml"},{url:path.replace(".fnt",".png"),type:"image"}],Handler.create(this,this._onLoaded));
	}

	/**
	*@private
	*/
	__proto._onLoaded=function(){
		this.parseFont(Loader.getRes(this._path),Loader.getRes(this._path.replace(".fnt",".png")));
		this._complete && this._complete.run();
	}

	/**
	*解析字体文件。
	*@param xml 字体文件XML。
	*@param texture 字体的纹理。
	*/
	__proto.parseFont=function(xml,texture){
		if (xml==null || texture==null)return;
		this._texture=texture;
		var tX=0;
		var tScale=1;
		var tInfo=xml.getElementsByTagName("info");
		if (!tInfo[0].getAttributeNode){
			return this.parseFont2(xml,texture);
		}
		this.fontSize=parseInt(tInfo[0].getAttributeNode("size").nodeValue);
		var tPadding=tInfo[0].getAttributeNode("padding").nodeValue;
		var tPaddingArray=tPadding.split(",");
		this._padding=[parseInt(tPaddingArray[0]),parseInt(tPaddingArray[1]),parseInt(tPaddingArray[2]),parseInt(tPaddingArray[3])];
		var chars;
		chars=xml.getElementsByTagName("char");
		var i=0;
		for (i=0;i < chars.length;i++){
			var tAttribute=chars[i];
			var tId=parseInt(tAttribute.getAttributeNode("id").nodeValue);
			var xOffset=parseInt(tAttribute.getAttributeNode("xoffset").nodeValue)/ tScale;
			var yOffset=parseInt(tAttribute.getAttributeNode("yoffset").nodeValue)/ tScale;
			var xAdvance=parseInt(tAttribute.getAttributeNode("xadvance").nodeValue)/ tScale;
			var region=new Rectangle();
			region.x=parseInt(tAttribute.getAttributeNode("x").nodeValue);
			region.y=parseInt(tAttribute.getAttributeNode("y").nodeValue);
			region.width=parseInt(tAttribute.getAttributeNode("width").nodeValue);
			region.height=parseInt(tAttribute.getAttributeNode("height").nodeValue);
			var tTexture=Texture.create(texture,region.x,region.y,region.width,region.height,xOffset,yOffset);
			this._maxWidth=Math.max(this._maxWidth,xAdvance+this.letterSpacing);
			this._fontCharDic[tId]=tTexture;
			this._fontWidthMap[tId]=xAdvance;
		}
	}

	/**
	*解析字体文件。
	*@param xml 字体文件XML。
	*@param texture 字体的纹理。
	*/
	__proto.parseFont2=function(xml,texture){
		if (xml==null || texture==null)return;
		this._texture=texture;
		var tX=0;
		var tScale=1;
		var tInfo=xml.getElementsByTagName("info");
		this.fontSize=parseInt(tInfo[0].attributes["size"].nodeValue);
		var tPadding=tInfo[0].attributes["padding"].nodeValue;
		var tPaddingArray=tPadding.split(",");
		this._padding=[parseInt(tPaddingArray[0]),parseInt(tPaddingArray[1]),parseInt(tPaddingArray[2]),parseInt(tPaddingArray[3])];
		var chars=xml.getElementsByTagName("char");
		var i=0;
		for (i=0;i < chars.length;i++){
			var tAttribute=chars[i].attributes;
			var tId=parseInt(tAttribute["id"].nodeValue);
			var xOffset=parseInt(tAttribute["xoffset"].nodeValue)/ tScale;
			var yOffset=parseInt(tAttribute["yoffset"].nodeValue)/ tScale;
			var xAdvance=parseInt(tAttribute["xadvance"].nodeValue)/ tScale;
			var region=new Rectangle();
			region.x=parseInt(tAttribute["x"].nodeValue);
			region.y=parseInt(tAttribute["y"].nodeValue);
			region.width=parseInt(tAttribute["width"].nodeValue);
			region.height=parseInt(tAttribute["height"].nodeValue);
			var tTexture=Texture.create(texture,region.x,region.y,region.width,region.height,xOffset,yOffset);
			this._maxWidth=Math.max(this._maxWidth,xAdvance+this.letterSpacing);
			this._fontCharDic[tId]=tTexture;
			this._fontWidthMap[tId]=xAdvance;
		}
	}

	/**
	*获取指定字符的字体纹理对象。
	*@param char 字符。
	*@return 指定的字体纹理对象。
	*/
	__proto.getCharTexture=function(char){
		return this._fontCharDic[char.charCodeAt(0)];
	}

	/**
	*销毁位图字体，调用Text.unregisterBitmapFont 时，默认会销毁。
	*/
	__proto.destroy=function(){
		if (this._texture){
			for (var p in this._fontCharDic){
				var tTexture=this._fontCharDic[p];
				if (tTexture)tTexture.destroy();
			}
			this._texture.destroy();
			this._fontCharDic=null;
			this._fontWidthMap=null;
			this._texture=null;
			this._complete=null;
			this._padding=null;
		}
	}

	/**
	*设置空格的宽（如果字体库有空格，这里就可以不用设置了）。
	*@param spaceWidth 宽度，单位为像素。
	*/
	__proto.setSpaceWidth=function(spaceWidth){
		this._spaceWidth=spaceWidth;
	}

	/**
	*获取指定字符的宽度。
	*@param char 字符。
	*@return 宽度。
	*/
	__proto.getCharWidth=function(char){
		var code=char.charCodeAt(0);
		if (this._fontWidthMap[code])return this._fontWidthMap[code]+this.letterSpacing;
		if (char===" ")return this._spaceWidth+this.letterSpacing;
		return 0;
	}

	/**
	*获取指定文本内容的宽度。
	*@param text 文本内容。
	*@return 宽度。
	*/
	__proto.getTextWidth=function(text){
		var tWidth=0;
		for (var i=0,n=text.length;i < n;i++){
			tWidth+=this.getCharWidth(text.charAt(i));
		}
		return tWidth;
	}

	/**
	*获取最大字符宽度。
	*/
	__proto.getMaxWidth=function(){
		return this._maxWidth;
	}

	/**
	*获取最大字符高度。
	*/
	__proto.getMaxHeight=function(){
		return this.fontSize;
	}

	/**
	*@private
	*将指定的文本绘制到指定的显示对象上。
	*/
	__proto._drawText=function(text,sprite,drawX,drawY,align,width){
		var tWidth=this.getTextWidth(text);
		var tTexture;
		var dx=0;
		align==="center" && (dx=(width-tWidth)/ 2);
		align==="right" && (dx=(width-tWidth));
		var tx=0;
		for (var i=0,n=text.length;i < n;i++){
			tTexture=this.getCharTexture(text.charAt(i));
			if (tTexture){
				sprite.graphics.drawImage(tTexture,drawX+tx+dx,drawY);
				tx+=this.getCharWidth(text.charAt(i));
			}
		}
	}

	return BitmapFont;
})()


//class laya.display.cmd.AlphaCmd
var AlphaCmd=(function(){
	function AlphaCmd(){
		/**
		*透明度
		*/
		//this.alpha=NaN;
	}

	__class(AlphaCmd,'laya.display.cmd.AlphaCmd');
	var __proto=AlphaCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("AlphaCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.alpha(this.alpha);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "Alpha";
	});

	AlphaCmd.create=function(alpha){
		var cmd=Pool.getItemByClass("AlphaCmd",AlphaCmd);
		cmd.alpha=alpha;
		return cmd;
	}

	AlphaCmd.ID="Alpha";
	return AlphaCmd;
})()


//class laya.display.cmd.ClipRectCmd
var ClipRectCmd=(function(){
	function ClipRectCmd(){
		/**
		*X 轴偏移量。
		*/
		//this.x=NaN;
		/**
		*Y 轴偏移量。
		*/
		//this.y=NaN;
		/**
		*宽度。
		*/
		//this.width=NaN;
		/**
		*高度。
		*/
		//this.height=NaN;
	}

	__class(ClipRectCmd,'laya.display.cmd.ClipRectCmd');
	var __proto=ClipRectCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("ClipRectCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.clipRect(this.x+gx,this.y+gy,this.width,this.height);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "ClipRect";
	});

	ClipRectCmd.create=function(x,y,width,height){
		var cmd=Pool.getItemByClass("ClipRectCmd",ClipRectCmd);
		cmd.x=x;
		cmd.y=y;
		cmd.width=width;
		cmd.height=height;
		return cmd;
	}

	ClipRectCmd.ID="ClipRect";
	return ClipRectCmd;
})()


//class laya.display.cmd.DrawCircleCmd
var DrawCircleCmd=(function(){
	function DrawCircleCmd(){
		/**
		*圆点X 轴位置。
		*/
		//this.x=NaN;
		/**
		*圆点Y 轴位置。
		*/
		//this.y=NaN;
		/**
		*半径。
		*/
		//this.radius=NaN;
		/**
		*填充颜色，或者填充绘图的渐变对象。
		*/
		//this.fillColor=null;
		/**
		*（可选）边框颜色，或者填充绘图的渐变对象。
		*/
		//this.lineColor=null;
		/**
		*（可选）边框宽度。
		*/
		//this.lineWidth=NaN;
		/**@private */
		//this.vid=0;
	}

	__class(DrawCircleCmd,'laya.display.cmd.DrawCircleCmd');
	var __proto=DrawCircleCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.fillColor=null;
		this.lineColor=null;
		Pool.recover("DrawCircleCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._drawCircle(this.x+gx,this.y+gy,this.radius,this.fillColor,this.lineColor,this.lineWidth,this.vid);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawCircle";
	});

	DrawCircleCmd.create=function(x,y,radius,fillColor,lineColor,lineWidth,vid){
		var cmd=Pool.getItemByClass("DrawCircleCmd",DrawCircleCmd);
		cmd.x=x;
		cmd.y=y;
		cmd.radius=radius;
		cmd.fillColor=fillColor;
		cmd.lineColor=lineColor;
		cmd.lineWidth=lineWidth;
		cmd.vid=vid;
		return cmd;
	}

	DrawCircleCmd.ID="DrawCircle";
	return DrawCircleCmd;
})()


//class laya.display.cmd.DrawCurvesCmd
var DrawCurvesCmd=(function(){
	function DrawCurvesCmd(){
		/**
		*开始绘制的 X 轴位置。
		*/
		//this.x=NaN;
		/**
		*开始绘制的 Y 轴位置。
		*/
		//this.y=NaN;
		/**
		*线段的点集合，格式[controlX,controlY,anchorX,anchorY...]。
		*/
		//this.points=null;
		/**
		*线段颜色，或者填充绘图的渐变对象。
		*/
		//this.lineColor=null;
		/**
		*（可选）线段宽度。
		*/
		//this.lineWidth=NaN;
	}

	__class(DrawCurvesCmd,'laya.display.cmd.DrawCurvesCmd');
	var __proto=DrawCurvesCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.points=null;
		this.lineColor=null;
		Pool.recover("DrawCurvesCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.drawCurves(this.x+gx,this.y+gy,this.points,this.lineColor,this.lineWidth);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawCurves";
	});

	DrawCurvesCmd.create=function(x,y,points,lineColor,lineWidth){
		var cmd=Pool.getItemByClass("DrawCurvesCmd",DrawCurvesCmd);
		cmd.x=x;
		cmd.y=y;
		cmd.points=points;
		cmd.lineColor=lineColor;
		cmd.lineWidth=lineWidth;
		return cmd;
	}

	DrawCurvesCmd.ID="DrawCurves";
	return DrawCurvesCmd;
})()


//class laya.display.cmd.DrawImageCmd
var DrawImageCmd=(function(){
	function DrawImageCmd(){
		/**
		*纹理。
		*/
		//this.texture=null;
		/**
		*（可选）X轴偏移量。
		*/
		//this.x=NaN;
		/**
		*（可选）Y轴偏移量。
		*/
		//this.y=NaN;
		/**
		*（可选）宽度。
		*/
		//this.width=NaN;
		/**
		*（可选）高度。
		*/
		//this.height=NaN;
	}

	__class(DrawImageCmd,'laya.display.cmd.DrawImageCmd');
	var __proto=DrawImageCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.texture._removeReference();
		this.texture=null;
		Pool.recover("DrawImageCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.drawTexture(this.texture,this.x+gx,this.y+gy,this.width,this.height);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawImage";
	});

	DrawImageCmd.create=function(texture,x,y,width,height){
		var cmd=Pool.getItemByClass("DrawImageCmd",DrawImageCmd);
		cmd.texture=texture;
		texture._addReference();
		cmd.x=x;
		cmd.y=y;
		cmd.width=width;
		cmd.height=height;
		return cmd;
	}

	DrawImageCmd.ID="DrawImage";
	return DrawImageCmd;
})()


//class laya.display.cmd.DrawLineCmd
var DrawLineCmd=(function(){
	function DrawLineCmd(){
		/**
		*X轴开始位置。
		*/
		//this.fromX=NaN;
		/**
		*Y轴开始位置。
		*/
		//this.fromY=NaN;
		/**
		*X轴结束位置。
		*/
		//this.toX=NaN;
		/**
		*Y轴结束位置。
		*/
		//this.toY=NaN;
		/**
		*颜色。
		*/
		//this.lineColor=null;
		/**
		*（可选）线条宽度。
		*/
		//this.lineWidth=NaN;
		/**@private */
		//this.vid=0;
	}

	__class(DrawLineCmd,'laya.display.cmd.DrawLineCmd');
	var __proto=DrawLineCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("DrawLineCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._drawLine(gx,gy,this.fromX,this.fromY,this.toX,this.toY,this.lineColor,this.lineWidth,this.vid);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawLine";
	});

	DrawLineCmd.create=function(fromX,fromY,toX,toY,lineColor,lineWidth,vid){
		var cmd=Pool.getItemByClass("DrawLineCmd",DrawLineCmd);
		cmd.fromX=fromX;
		cmd.fromY=fromY;
		cmd.toX=toX;
		cmd.toY=toY;
		cmd.lineColor=lineColor;
		cmd.lineWidth=lineWidth;
		cmd.vid=vid;
		return cmd;
	}

	DrawLineCmd.ID="DrawLine";
	return DrawLineCmd;
})()


//class laya.display.cmd.DrawLinesCmd
var DrawLinesCmd=(function(){
	function DrawLinesCmd(){
		/**
		*开始绘制的X轴位置。
		*/
		//this.x=NaN;
		/**
		*开始绘制的Y轴位置。
		*/
		//this.y=NaN;
		/**
		*线段的点集合。格式:[x1,y1,x2,y2,x3,y3...]。
		*/
		//this.points=null;
		/**
		*线段颜色，或者填充绘图的渐变对象。
		*/
		//this.lineColor=null;
		/**
		*（可选）线段宽度。
		*/
		//this.lineWidth=NaN;
		/**@private */
		//this.vid=0;
	}

	__class(DrawLinesCmd,'laya.display.cmd.DrawLinesCmd');
	var __proto=DrawLinesCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.points=null;
		this.lineColor=null;
		Pool.recover("DrawLinesCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._drawLines(this.x+gx,this.y+gy,this.points,this.lineColor,this.lineWidth,this.vid);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawLines";
	});

	DrawLinesCmd.create=function(x,y,points,lineColor,lineWidth,vid){
		var cmd=Pool.getItemByClass("DrawLinesCmd",DrawLinesCmd);
		cmd.x=x;
		cmd.y=y;
		cmd.points=points;
		cmd.lineColor=lineColor;
		cmd.lineWidth=lineWidth;
		cmd.vid=vid;
		return cmd;
	}

	DrawLinesCmd.ID="DrawLines";
	return DrawLinesCmd;
})()


//class laya.display.cmd.DrawPathCmd
var DrawPathCmd=(function(){
	function DrawPathCmd(){
		/**
		*开始绘制的 X 轴位置。
		*/
		//this.x=NaN;
		/**
		*开始绘制的 Y 轴位置。
		*/
		//this.y=NaN;
		/**
		*路径集合，路径支持以下格式：[["moveTo",x,y],["lineTo",x,y],["arcTo",x1,y1,x2,y2,r],["closePath"]]。
		*/
		//this.paths=null;
		/**
		*（可选）刷子定义，支持以下设置{fillStyle:"#FF0000"}。
		*/
		//this.brush=null;
		/**
		*（可选）画笔定义，支持以下设置{strokeStyle,lineWidth,lineJoin:"bevel|round|miter",lineCap:"butt|round|square",miterLimit}。
		*/
		//this.pen=null;
	}

	__class(DrawPathCmd,'laya.display.cmd.DrawPathCmd');
	var __proto=DrawPathCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.paths=null;
		this.brush=null;
		this.pen=null;
		Pool.recover("DrawPathCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._drawPath(this.x+gx,this.y+gy,this.paths,this.brush,this.pen);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawPath";
	});

	DrawPathCmd.create=function(x,y,paths,brush,pen){
		var cmd=Pool.getItemByClass("DrawPathCmd",DrawPathCmd);
		cmd.x=x;
		cmd.y=y;
		cmd.paths=paths;
		cmd.brush=brush;
		cmd.pen=pen;
		return cmd;
	}

	DrawPathCmd.ID="DrawPath";
	return DrawPathCmd;
})()


//class laya.display.cmd.DrawPieCmd
var DrawPieCmd=(function(){
	function DrawPieCmd(){
		/**
		*开始绘制的 X 轴位置。
		*/
		//this.x=NaN;
		/**
		*开始绘制的 Y 轴位置。
		*/
		//this.y=NaN;
		/**
		*扇形半径。
		*/
		//this.radius=NaN;
		//this._startAngle=NaN;
		//this._endAngle=NaN;
		/**
		*填充颜色，或者填充绘图的渐变对象。
		*/
		//this.fillColor=null;
		/**
		*（可选）边框颜色，或者填充绘图的渐变对象。
		*/
		//this.lineColor=null;
		/**
		*（可选）边框宽度。
		*/
		//this.lineWidth=NaN;
		/**@private */
		//this.vid=0;
	}

	__class(DrawPieCmd,'laya.display.cmd.DrawPieCmd');
	var __proto=DrawPieCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.fillColor=null;
		this.lineColor=null;
		Pool.recover("DrawPieCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._drawPie(this.x+gx,this.y+gy,this.radius,this._startAngle,this._endAngle,this.fillColor,this.lineColor,this.lineWidth,this.vid);
	}

	/**
	*开始角度。
	*/
	__getset(0,__proto,'startAngle',function(){
		return this._startAngle *180 / Math.PI;
		},function(value){
		this._startAngle=value *Math.PI / 180;
	});

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawPie";
	});

	/**
	*结束角度。
	*/
	__getset(0,__proto,'endAngle',function(){
		return this._endAngle *180 / Math.PI;
		},function(value){
		this._endAngle=value *Math.PI / 180;
	});

	DrawPieCmd.create=function(x,y,radius,startAngle,endAngle,fillColor,lineColor,lineWidth,vid){
		var cmd=Pool.getItemByClass("DrawPieCmd",DrawPieCmd);
		cmd.x=x;
		cmd.y=y;
		cmd.radius=radius;
		cmd._startAngle=startAngle;
		cmd._endAngle=endAngle;
		cmd.fillColor=fillColor;
		cmd.lineColor=lineColor;
		cmd.lineWidth=lineWidth;
		cmd.vid=vid;
		return cmd;
	}

	DrawPieCmd.ID="DrawPie";
	return DrawPieCmd;
})()


//class laya.display.cmd.DrawPolyCmd
var DrawPolyCmd=(function(){
	function DrawPolyCmd(){
		/**
		*开始绘制的 X 轴位置。
		*/
		//this.x=NaN;
		/**
		*开始绘制的 Y 轴位置。
		*/
		//this.y=NaN;
		/**
		*多边形的点集合。
		*/
		//this.points=null;
		/**
		*填充颜色，或者填充绘图的渐变对象。
		*/
		//this.fillColor=null;
		/**
		*（可选）边框颜色，或者填充绘图的渐变对象。
		*/
		//this.lineColor=null;
		/**
		*可选）边框宽度。
		*/
		//this.lineWidth=NaN;
		/**@private */
		//this.isConvexPolygon=false;
		/**@private */
		//this.vid=0;
	}

	__class(DrawPolyCmd,'laya.display.cmd.DrawPolyCmd');
	var __proto=DrawPolyCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.points=null;
		this.fillColor=null;
		this.lineColor=null;
		Pool.recover("DrawPolyCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._drawPoly(this.x+gx,this.y+gy,this.points,this.fillColor,this.lineColor,this.lineWidth,this.isConvexPolygon,this.vid);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawPoly";
	});

	DrawPolyCmd.create=function(x,y,points,fillColor,lineColor,lineWidth,isConvexPolygon,vid){
		var cmd=Pool.getItemByClass("DrawPolyCmd",DrawPolyCmd);
		cmd.x=x;
		cmd.y=y;
		cmd.points=points;
		cmd.fillColor=fillColor;
		cmd.lineColor=lineColor;
		cmd.lineWidth=lineWidth;
		cmd.isConvexPolygon=isConvexPolygon;
		cmd.vid=vid;
		return cmd;
	}

	DrawPolyCmd.ID="DrawPoly";
	return DrawPolyCmd;
})()


//class laya.display.cmd.DrawRectCmd
var DrawRectCmd=(function(){
	function DrawRectCmd(){
		/**
		*开始绘制的 X 轴位置。
		*/
		//this.x=NaN;
		/**
		*开始绘制的 Y 轴位置。
		*/
		//this.y=NaN;
		/**
		*矩形宽度。
		*/
		//this.width=NaN;
		/**
		*矩形高度。
		*/
		//this.height=NaN;
		/**
		*填充颜色，或者填充绘图的渐变对象。
		*/
		//this.fillColor=null;
		/**
		*（可选）边框颜色，或者填充绘图的渐变对象。
		*/
		//this.lineColor=null;
		/**
		*（可选）边框宽度。
		*/
		//this.lineWidth=NaN;
	}

	__class(DrawRectCmd,'laya.display.cmd.DrawRectCmd');
	var __proto=DrawRectCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.fillColor=null;
		this.lineColor=null;
		Pool.recover("DrawRectCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.drawRect(this.x+gx,this.y+gy,this.width,this.height,this.fillColor,this.lineColor,this.lineWidth);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawRect";
	});

	DrawRectCmd.create=function(x,y,width,height,fillColor,lineColor,lineWidth){
		var cmd=Pool.getItemByClass("DrawRectCmd",DrawRectCmd);
		cmd.x=x;
		cmd.y=y;
		cmd.width=width;
		cmd.height=height;
		cmd.fillColor=fillColor;
		cmd.lineColor=lineColor;
		cmd.lineWidth=lineWidth;
		return cmd;
	}

	DrawRectCmd.ID="DrawRect";
	return DrawRectCmd;
})()


//class laya.display.cmd.DrawTextureCmd
var DrawTextureCmd=(function(){
	function DrawTextureCmd(){
		/**
		*纹理。
		*/
		//this.texture=null;
		/**
		*（可选）X轴偏移量。
		*/
		//this.x=NaN;
		/**
		*（可选）Y轴偏移量。
		*/
		//this.y=NaN;
		/**
		*（可选）宽度。
		*/
		//this.width=NaN;
		/**
		*（可选）高度。
		*/
		//this.height=NaN;
		/**
		*（可选）矩阵信息。
		*/
		//this.matrix=null;
		/**
		*（可选）透明度。
		*/
		//this.alpha=NaN;
		/**
		*（可选）颜色滤镜。
		*/
		//this.color=null;
		/**
		*（可选）混合模式。
		*/
		//this.blendMode=null;
	}

	__class(DrawTextureCmd,'laya.display.cmd.DrawTextureCmd');
	var __proto=DrawTextureCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.texture._removeReference();
		this.texture=null;
		this.matrix=null;
		Pool.recover("DrawTextureCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.drawTextureWithTransform(this.texture,this.x,this.y,this.width,this.height,this.matrix,gx,gy,this.alpha,this.blendMode);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawTexture";
	});

	DrawTextureCmd.create=function(texture,x,y,width,height,matrix,alpha,color,blendMode){
		var cmd=Pool.getItemByClass("DrawTextureCmd",DrawTextureCmd);
		cmd.texture=texture;
		texture._addReference();
		cmd.x=x;
		cmd.y=y;
		cmd.width=width;
		cmd.height=height;
		cmd.matrix=matrix;
		cmd.alpha=alpha;
		cmd.color=color;
		cmd.blendMode=blendMode;
		return cmd;
	}

	DrawTextureCmd.ID="DrawTexture";
	return DrawTextureCmd;
})()


//class laya.display.cmd.DrawTexturesCmd
var DrawTexturesCmd=(function(){
	function DrawTexturesCmd(){
		/**
		*纹理。
		*/
		//this.texture=null;
		/**
		*绘制次数和坐标。
		*/
		//this.pos=null;
	}

	__class(DrawTexturesCmd,'laya.display.cmd.DrawTexturesCmd');
	var __proto=DrawTexturesCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.texture._removeReference();
		this.texture=null;
		this.pos=null;
		Pool.recover("DrawTexturesCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.drawTextures(this.texture,this.pos,gx,gy);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawTextures";
	});

	DrawTexturesCmd.create=function(texture,pos){
		var cmd=Pool.getItemByClass("DrawTexturesCmd",DrawTexturesCmd);
		cmd.texture=texture;
		texture._addReference();
		cmd.pos=pos;
		return cmd;
	}

	DrawTexturesCmd.ID="DrawTextures";
	return DrawTexturesCmd;
})()


//class laya.display.cmd.DrawTrianglesCmd
var DrawTrianglesCmd=(function(){
	function DrawTrianglesCmd(){
		/**
		*纹理。
		*/
		//this.texture=null;
		/**
		*X轴偏移量。
		*/
		//this.x=NaN;
		/**
		*Y轴偏移量。
		*/
		//this.y=NaN;
		/**
		*顶点数组。
		*/
		//this.vertices=null;
		/**
		*UV数据。
		*/
		//this.uvs=null;
		/**
		*顶点索引。
		*/
		//this.indices=null;
		/**
		*缩放矩阵。
		*/
		//this.matrix=null;
		/**
		*alpha
		*/
		//this.alpha=NaN;
		/**
		*blend模式
		*/
		//this.blendMode=null;
		/**
		*颜色变换
		*/
		//this.color=null;
	}

	__class(DrawTrianglesCmd,'laya.display.cmd.DrawTrianglesCmd');
	var __proto=DrawTrianglesCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.texture=null;
		this.vertices=null;
		this.uvs=null;
		this.indices=null;
		this.matrix=null;
		Pool.recover("DrawTrianglesCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.drawTriangles(this.texture,this.x+gx,this.y+gy,this.vertices,this.uvs,this.indices,this.matrix,this.alpha,this.color,this.blendMode);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "DrawTriangles";
	});

	DrawTrianglesCmd.create=function(texture,x,y,vertices,uvs,indices,matrix,alpha,color,blendMode){
		var cmd=Pool.getItemByClass("DrawTrianglesCmd",DrawTrianglesCmd);
		cmd.texture=texture;
		cmd.x=x;
		cmd.y=y;
		cmd.vertices=vertices;
		cmd.uvs=uvs;
		cmd.indices=indices;
		cmd.matrix=matrix;
		cmd.alpha=alpha;
		if (color){
			cmd.color=new ColorFilter();
			var c=ColorUtils.create(color).arrColor;
			cmd.color.color(c[0]*255,c[1]*255,c[2]*255,c[3]*255);
		}
		cmd.blendMode=blendMode;
		return cmd;
	}

	DrawTrianglesCmd.ID="DrawTriangles";
	return DrawTrianglesCmd;
})()


//class laya.display.cmd.FillBorderTextCmd
var FillBorderTextCmd=(function(){
	function FillBorderTextCmd(){
		/**
		*在画布上输出的文本。
		*/
		//this.text=null;
		/**
		*开始绘制文本的 x 坐标位置（相对于画布）。
		*/
		//this.x=NaN;
		/**
		*开始绘制文本的 y 坐标位置（相对于画布）。
		*/
		//this.y=NaN;
		/**
		*定义字体和字号，比如"20px Arial"。
		*/
		//this.font=null;
		/**
		*定义文本颜色，比如"#ff0000"。
		*/
		//this.fillColor=null;
		/**
		*定义镶边文本颜色。
		*/
		//this.borderColor=null;
		/**
		*镶边线条宽度。
		*/
		//this.lineWidth=NaN;
		/**
		*文本对齐方式，可选值："left"，"center"，"right"。
		*/
		//this.textAlign=null;
	}

	__class(FillBorderTextCmd,'laya.display.cmd.FillBorderTextCmd');
	var __proto=FillBorderTextCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("FillBorderTextCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.fillBorderText(this.text,this.x+gx,this.y+gy,this.font,this.fillColor,this.borderColor,this.lineWidth,this.textAlign);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "FillBorderText";
	});

	FillBorderTextCmd.create=function(text,x,y,font,fillColor,borderColor,lineWidth,textAlign){
		var cmd=Pool.getItemByClass("FillBorderTextCmd",FillBorderTextCmd);
		cmd.text=text;
		cmd.x=x;
		cmd.y=y;
		cmd.font=font;
		cmd.fillColor=fillColor;
		cmd.borderColor=borderColor;
		cmd.lineWidth=lineWidth;
		cmd.textAlign=textAlign;
		return cmd;
	}

	FillBorderTextCmd.ID="FillBorderText";
	return FillBorderTextCmd;
})()


//class laya.display.cmd.FillBorderWordsCmd
var FillBorderWordsCmd=(function(){
	function FillBorderWordsCmd(){
		/**
		*文字数组
		*/
		//this.words=null;
		/**
		*开始绘制文本的 x 坐标位置（相对于画布）。
		*/
		//this.x=NaN;
		/**
		*开始绘制文本的 y 坐标位置（相对于画布）。
		*/
		//this.y=NaN;
		/**
		*定义字体和字号，比如"20px Arial"。
		*/
		//this.font=null;
		/**
		*定义文本颜色，比如"#ff0000"。
		*/
		//this.fillColor=null;
		/**
		*定义镶边文本颜色。
		*/
		//this.borderColor=null;
		/**
		*镶边线条宽度。
		*/
		//this.lineWidth=0;
	}

	__class(FillBorderWordsCmd,'laya.display.cmd.FillBorderWordsCmd');
	var __proto=FillBorderWordsCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.words=null;
		Pool.recover("FillBorderWordsCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.fillBorderWords(this.words,this.x+gx,this.y+gy,this.font,this.fillColor,this.borderColor,this.lineWidth);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "FillBorderWords";
	});

	FillBorderWordsCmd.create=function(words,x,y,font,fillColor,borderColor,lineWidth){
		var cmd=Pool.getItemByClass("FillBorderWordsCmd",FillBorderWordsCmd);
		cmd.words=words;
		cmd.x=x;
		cmd.y=y;
		cmd.font=font;
		cmd.fillColor=fillColor;
		cmd.borderColor=borderColor;
		cmd.lineWidth=lineWidth;
		return cmd;
	}

	FillBorderWordsCmd.ID="FillBorderWords";
	return FillBorderWordsCmd;
})()


//class laya.display.cmd.FillTextCmd
var FillTextCmd=(function(){
	function FillTextCmd(){
		//this._text=null;
		/**@private */
		this._textIsWorldText=false;
		/**
		*开始绘制文本的 x 坐标位置（相对于画布）。
		*/
		//this.x=NaN;
		/**
		*开始绘制文本的 y 坐标位置（相对于画布）。
		*/
		//this.y=NaN;
		//this._font=null;
		//this._color=null;
		//this._textAlign=null;
		this._fontColor=0xffffffff;
		this._strokeColor=0;
		this._nTexAlign=0;
		this._fontObj=FillTextCmd._defFontObj;
	}

	__class(FillTextCmd,'laya.display.cmd.FillTextCmd');
	var __proto=FillTextCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("FillTextCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		if (this._textIsWorldText && context._fast_filltext){
			context._fast_filltext(this._text,this.x+gx,this.y+gy,this._fontObj,this._fontColor,0,0,this._nTexAlign,0);;
		}else
		context.drawText(this._text,this.x+gx,this.y+gy,this._font,this._color,this._textAlign);
	}

	/**
	*在画布上输出的文本。
	*/
	__getset(0,__proto,'text',function(){
		return this._text;
		},function(value){
		this._text=value;
		this._textIsWorldText=(value instanceof laya.utils.WordText );
		this._textIsWorldText && (this._text).cleanCache();
	});

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "FillText";
	});

	/**
	*定义文本颜色，比如"#ff0000"。
	*/
	__getset(0,__proto,'color',function(){
		return this._color;
		},function(value){
		this._color=value;
		this._fontColor=ColorUtils.create(value).numColor;
		this._textIsWorldText && (this._text).cleanCache();
	});

	/**
	*定义字号和字体，比如"20px Arial"。
	*/
	__getset(0,__proto,'font',function(){
		return this._font;
		},function(value){
		this._font=value;
		if (Render.isWebGL || Render.isConchApp){
			this._fontObj=FontInfo.Parse(value);
		}
		this._textIsWorldText && (this._text).cleanCache();
	});

	/**
	*文本对齐方式，可选值："left"，"center"，"right"。
	*/
	__getset(0,__proto,'textAlign',function(){
		return this._textAlign;
		},function(value){
		this._textAlign=value;
		switch (value){
			case 'center':
				this._nTexAlign=Context.ENUM_TEXTALIGN_CENTER;
				break ;
			case 'right':
				this._nTexAlign=Context.ENUM_TEXTALIGN_RIGHT;
				break ;
			default :
				this._nTexAlign=Context.ENUM_TEXTALIGN_DEFAULT;
			}
		this._textIsWorldText && (this._text).cleanCache();
	});

	FillTextCmd.create=function(text,x,y,font,color,textAlign){
		var cmd=Pool.getItemByClass("FillTextCmd",FillTextCmd);
		cmd.text=text;
		cmd._textIsWorldText=(text instanceof laya.utils.WordText );
		cmd.x=x;
		cmd.y=y;
		cmd.font=font;
		cmd.color=color;
		cmd.textAlign=textAlign;
		return cmd;
	}

	FillTextCmd.ID="FillText";
	__static(FillTextCmd,
	['_defFontObj',function(){return this._defFontObj=new FontInfo(null);}
	]);
	return FillTextCmd;
})()


//class laya.display.cmd.FillTextureCmd
var FillTextureCmd=(function(){
	function FillTextureCmd(){
		/**
		*纹理。
		*/
		//this.texture=null;
		/**
		*X轴偏移量。
		*/
		//this.x=NaN;
		/**
		*Y轴偏移量。
		*/
		//this.y=NaN;
		/**
		*（可选）宽度。
		*/
		//this.width=NaN;
		/**
		*（可选）高度。
		*/
		//this.height=NaN;
		/**
		*（可选）填充类型 repeat|repeat-x|repeat-y|no-repeat
		*/
		//this.type=null;
		/**
		*（可选）贴图纹理偏移
		*/
		//this.offset=null;
		/**@private */
		//this.other=null;
	}

	__class(FillTextureCmd,'laya.display.cmd.FillTextureCmd');
	var __proto=FillTextureCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.texture=null;
		this.offset=null;
		this.other=null;
		Pool.recover("FillTextureCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.fillTexture(this.texture,this.x+gx,this.y+gy,this.width,this.height,this.type,this.offset,this.other);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "FillTexture";
	});

	FillTextureCmd.create=function(texture,x,y,width,height,type,offset,other){
		var cmd=Pool.getItemByClass("FillTextureCmd",FillTextureCmd);
		cmd.texture=texture;
		cmd.x=x;
		cmd.y=y;
		cmd.width=width;
		cmd.height=height;
		cmd.type=type;
		cmd.offset=offset;
		cmd.other=other;
		return cmd;
	}

	FillTextureCmd.ID="FillTexture";
	return FillTextureCmd;
})()


//class laya.display.cmd.FillWordsCmd
var FillWordsCmd=(function(){
	function FillWordsCmd(){
		/**
		*文字数组
		*/
		//this.words=null;
		/**
		*开始绘制文本的 x 坐标位置（相对于画布）。
		*/
		//this.x=NaN;
		/**
		*开始绘制文本的 y 坐标位置（相对于画布）。
		*/
		//this.y=NaN;
		/**
		*定义字体和字号，比如"20px Arial"。
		*/
		//this.font=null;
		/**
		*定义文本颜色，比如"#ff0000"。
		*/
		//this.color=null;
	}

	__class(FillWordsCmd,'laya.display.cmd.FillWordsCmd');
	var __proto=FillWordsCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.words=null;
		Pool.recover("FillWordsCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.fillWords(this.words,this.x+gx,this.y+gy,this.font,this.color);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "FillWords";
	});

	FillWordsCmd.create=function(words,x,y,font,color){
		var cmd=Pool.getItemByClass("FillWordsCmd",FillWordsCmd);
		cmd.words=words;
		cmd.x=x;
		cmd.y=y;
		cmd.font=font;
		cmd.color=color;
		return cmd;
	}

	FillWordsCmd.ID="FillWords";
	return FillWordsCmd;
})()


//class laya.display.cmd.RestoreCmd
var RestoreCmd=(function(){
	function RestoreCmd(){}
	__class(RestoreCmd,'laya.display.cmd.RestoreCmd');
	var __proto=RestoreCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("RestoreCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.restore();
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "Restore";
	});

	RestoreCmd.create=function(){
		var cmd=Pool.getItemByClass("RestoreCmd",RestoreCmd);
		return cmd;
	}

	RestoreCmd.ID="Restore";
	return RestoreCmd;
})()


//class laya.display.cmd.RotateCmd
var RotateCmd=(function(){
	function RotateCmd(){
		/**
		*旋转角度，以弧度计。
		*/
		//this.angle=NaN;
		/**
		*（可选）水平方向轴心点坐标。
		*/
		//this.pivotX=NaN;
		/**
		*（可选）垂直方向轴心点坐标。
		*/
		//this.pivotY=NaN;
	}

	__class(RotateCmd,'laya.display.cmd.RotateCmd');
	var __proto=RotateCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("RotateCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._rotate(this.angle,this.pivotX+gx,this.pivotY+gy);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "Rotate";
	});

	RotateCmd.create=function(angle,pivotX,pivotY){
		var cmd=Pool.getItemByClass("RotateCmd",RotateCmd);
		cmd.angle=angle;
		cmd.pivotX=pivotX;
		cmd.pivotY=pivotY;
		return cmd;
	}

	RotateCmd.ID="Rotate";
	return RotateCmd;
})()


//class laya.display.cmd.SaveCmd
var SaveCmd=(function(){
	function SaveCmd(){}
	__class(SaveCmd,'laya.display.cmd.SaveCmd');
	var __proto=SaveCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("SaveCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.save();
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "Save";
	});

	SaveCmd.create=function(){
		var cmd=Pool.getItemByClass("SaveCmd",SaveCmd);
		return cmd;
	}

	SaveCmd.ID="Save";
	return SaveCmd;
})()


//class laya.display.cmd.ScaleCmd
var ScaleCmd=(function(){
	function ScaleCmd(){
		/**
		*水平方向缩放值。
		*/
		//this.scaleX=NaN;
		/**
		*垂直方向缩放值。
		*/
		//this.scaleY=NaN;
		/**
		*（可选）水平方向轴心点坐标。
		*/
		//this.pivotX=NaN;
		/**
		*（可选）垂直方向轴心点坐标。
		*/
		//this.pivotY=NaN;
	}

	__class(ScaleCmd,'laya.display.cmd.ScaleCmd');
	var __proto=ScaleCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("ScaleCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._scale(this.scaleX,this.scaleY,this.pivotX+gx,this.pivotY+gy);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "Scale";
	});

	ScaleCmd.create=function(scaleX,scaleY,pivotX,pivotY){
		var cmd=Pool.getItemByClass("ScaleCmd",ScaleCmd);
		cmd.scaleX=scaleX;
		cmd.scaleY=scaleY;
		cmd.pivotX=pivotX;
		cmd.pivotY=pivotY;
		return cmd;
	}

	ScaleCmd.ID="Scale";
	return ScaleCmd;
})()


//class laya.display.cmd.StrokeTextCmd
var StrokeTextCmd=(function(){
	function StrokeTextCmd(){
		/**
		*在画布上输出的文本。
		*/
		//this.text=null;
		/**
		*开始绘制文本的 x 坐标位置（相对于画布）。
		*/
		//this.x=NaN;
		/**
		*开始绘制文本的 y 坐标位置（相对于画布）。
		*/
		//this.y=NaN;
		/**
		*定义字体和字号，比如"20px Arial"。
		*/
		//this.font=null;
		/**
		*定义文本颜色，比如"#ff0000"。
		*/
		//this.color=null;
		/**
		*线条宽度。
		*/
		//this.lineWidth=NaN;
		/**
		*文本对齐方式，可选值："left"，"center"，"right"。
		*/
		//this.textAlign=null;
	}

	__class(StrokeTextCmd,'laya.display.cmd.StrokeTextCmd');
	var __proto=StrokeTextCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("StrokeTextCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.strokeWord(this.text,this.x+gx,this.y+gy,this.font,this.color,this.lineWidth,this.textAlign);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "StrokeText";
	});

	StrokeTextCmd.create=function(text,x,y,font,color,lineWidth,textAlign){
		var cmd=Pool.getItemByClass("StrokeTextCmd",StrokeTextCmd);
		cmd.text=text;
		cmd.x=x;
		cmd.y=y;
		cmd.font=font;
		cmd.color=color;
		cmd.lineWidth=lineWidth;
		cmd.textAlign=textAlign;
		return cmd;
	}

	StrokeTextCmd.ID="StrokeText";
	return StrokeTextCmd;
})()


//class laya.display.cmd.TransformCmd
var TransformCmd=(function(){
	function TransformCmd(){
		/**
		*矩阵。
		*/
		//this.matrix=null;
		/**
		*（可选）水平方向轴心点坐标。
		*/
		//this.pivotX=NaN;
		/**
		*（可选）垂直方向轴心点坐标。
		*/
		//this.pivotY=NaN;
	}

	__class(TransformCmd,'laya.display.cmd.TransformCmd');
	var __proto=TransformCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		this.matrix=null;
		Pool.recover("TransformCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context._transform(this.matrix,this.pivotX+gx,this.pivotY+gy);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "Transform";
	});

	TransformCmd.create=function(matrix,pivotX,pivotY){
		var cmd=Pool.getItemByClass("TransformCmd",TransformCmd);
		cmd.matrix=matrix;
		cmd.pivotX=pivotX;
		cmd.pivotY=pivotY;
		return cmd;
	}

	TransformCmd.ID="Transform";
	return TransformCmd;
})()


//class laya.display.cmd.TranslateCmd
var TranslateCmd=(function(){
	function TranslateCmd(){
		/**
		*添加到水平坐标（x）上的值。
		*/
		//this.tx=NaN;
		/**
		*添加到垂直坐标（y）上的值。
		*/
		//this.ty=NaN;
	}

	__class(TranslateCmd,'laya.display.cmd.TranslateCmd');
	var __proto=TranslateCmd.prototype;
	/**
	*回收到对象池
	*/
	__proto.recover=function(){
		Pool.recover("TranslateCmd",this);
	}

	/**@private */
	__proto.run=function(context,gx,gy){
		context.translate(this.tx,this.ty);
	}

	/**@private */
	__getset(0,__proto,'cmdID',function(){
		return "Translate";
	});

	TranslateCmd.create=function(tx,ty){
		var cmd=Pool.getItemByClass("TranslateCmd",TranslateCmd);
		cmd.tx=tx;
		cmd.ty=ty;
		return cmd;
	}

	TranslateCmd.ID="Translate";
	return TranslateCmd;
})()


//class laya.display.css.BoundsStyle
var BoundsStyle=(function(){
	function BoundsStyle(){
		/**@private */
		//this.bounds=null;
		/**用户设的bounds*/
		//this.userBounds=null;
		/**缓存的bounds顶点,sprite计算bounds用*/
		//this.temBM=null;
	}

	__class(BoundsStyle,'laya.display.css.BoundsStyle');
	var __proto=BoundsStyle.prototype;
	/**
	*重置
	*/
	__proto.reset=function(){
		if(this.bounds)this.bounds.recover();
		if(this.userBounds)this.userBounds.recover();
		this.bounds=null;
		this.userBounds=null;
		this.temBM=null;
		return this;
	}

	/**
	*回收
	*/
	__proto.recover=function(){
		Pool.recover("BoundsStyle",this.reset());
	}

	BoundsStyle.create=function(){
		return Pool.getItemByClass("BoundsStyle",BoundsStyle);
	}

	return BoundsStyle;
})()


//class laya.display.css.CacheStyle
var CacheStyle=(function(){
	function CacheStyle(){
		/**当前实际的cache状态*/
		//this.cacheAs=null;
		/**是否开启canvas渲染*/
		//this.enableCanvasRender=false;
		/**用户设的cacheAs类型*/
		//this.userSetCache=null;
		/**是否需要为滤镜cache*/
		//this.cacheForFilters=false;
		/**是否为静态缓存*/
		//this.staticCache=false;
		/**是否需要刷新缓存*/
		//this.reCache=false;
		/**mask对象*/
		//this.mask=null;
		/**作为mask时的父对象*/
		//this.maskParent=null;
		/**滤镜数据*/
		//this.filters=null;
		/**当前缓存区域*/
		//this.cacheRect=null;
		/**当前使用的canvas*/
		//this.canvas=null;
		/**滤镜数据*/
		//this.filterCache=null;
		/**是否有发光滤镜*/
		//this.hasGlowFilter=false;
		this.reset();
	}

	__class(CacheStyle,'laya.display.css.CacheStyle');
	var __proto=CacheStyle.prototype;
	/**
	*是否需要Bitmap缓存
	*@return
	*/
	__proto.needBitmapCache=function(){
		return this.cacheForFilters || !!this.mask;
	}

	/**
	*是否需要开启canvas渲染
	*/
	__proto.needEnableCanvasRender=function(){
		return this.userSetCache !="none" || this.cacheForFilters || !!this.mask;
	}

	/**
	*释放cache的资源
	*/
	__proto.releaseContext=function(){
		if (this.canvas){
			Pool.recover("CacheCanvas",this.canvas);
			this.canvas.size(0,0);
			this.canvas=null;
		}
	}

	__proto.createContext=function(){
		if (!this.canvas){
			this.canvas=Pool.getItem("CacheCanvas")|| new HTMLCanvas(!Render.isWebGL);
			var tx=this.canvas.context;
			if (!tx){
				tx=this.canvas.getContext('2d');
			}
		}
	}

	/**
	*释放滤镜资源
	*/
	__proto.releaseFilterCache=function(){
		var fc=this.filterCache;
		if (fc){
			fc.destroy();
			fc.recycle();
			this.filterCache=null;
		}
	}

	/**
	*回收
	*/
	__proto.recover=function(){
		if (this===CacheStyle.EMPTY)return;
		Pool.recover("SpriteCache",this.reset());
	}

	/**
	*重置
	*/
	__proto.reset=function(){
		this.releaseContext();
		this.releaseFilterCache();
		this.cacheAs="none";
		this.enableCanvasRender=false;
		this.userSetCache="none";
		this.cacheForFilters=false;
		this.staticCache=false;
		this.reCache=true;
		this.mask=null;
		this.maskParent=null;
		this.filterCache=null;
		this.filters=null;
		this.hasGlowFilter=false;
		if(this.cacheRect)this.cacheRect.recover();
		this.cacheRect=null;
		return this
	}

	__proto._calculateCacheRect=function(sprite,tCacheType,x,y){
		var bWebGL=false;
		if (Render.isWebGL || Render.isConchApp){
			bWebGL=true;
		};
		var _cacheStyle=sprite._cacheStyle;
		if (!_cacheStyle.cacheRect)
			_cacheStyle.cacheRect=Rectangle.create();
		var tRec;
		if (!bWebGL || tCacheType==="bitmap"){
			tRec=sprite.getSelfBounds();
			if (!Render.isConchApp){
				tRec.width=tRec.width+16*2;
				tRec.height=tRec.height+16*2;
			}
			else{
				tRec.width=tRec.x+tRec.width+16*2;
				tRec.height=tRec.x+tRec.height+16*2;
			}
			tRec.x=tRec.x-sprite.pivotX;
			tRec.y=tRec.y-sprite.pivotY;
			tRec.x=tRec.x-16;
			tRec.y=tRec.y-16;
			tRec.x=Math.floor(tRec.x+x)-x;
			tRec.y=Math.floor(tRec.y+y)-y;
			tRec.width=Math.floor(tRec.width);
			tRec.height=Math.floor(tRec.height);
			_cacheStyle.cacheRect.copyFrom(tRec);
			}else {
			_cacheStyle.cacheRect.setTo(-sprite._style.pivotX,-sprite._style.pivotY,1,1);
		}
		tRec=_cacheStyle.cacheRect;
		var scaleX=bWebGL ? 1 :Browser.pixelRatio *Laya.stage.clientScaleX;
		var scaleY=bWebGL ? 1 :Browser.pixelRatio *Laya.stage.clientScaleY;
		if (!bWebGL){
			var chainScaleX=1;
			var chainScaleY=1;
			var tar;
			tar=sprite;
			while (tar && tar !=Laya.stage){
				chainScaleX *=tar.scaleX;
				chainScaleY *=tar.scaleY;
				tar=tar.parent;
			}
			if (chainScaleX > 1)scaleX *=chainScaleX;
			if (chainScaleY > 1)scaleY *=chainScaleY;
		}
		if (sprite._style.scrollRect){
			var scrollRect=sprite._style.scrollRect;
			tRec.x-=scrollRect.x;
			tRec.y-=scrollRect.y;
		}
		CacheStyle._scaleInfo.setTo(scaleX,scaleY);
		return CacheStyle._scaleInfo;
	}

	CacheStyle.create=function(){
		return Pool.getItemByClass("SpriteCache",CacheStyle);
	}

	CacheStyle.EMPTY=new CacheStyle();
	CacheStyle.CANVAS_EXTEND_EDGE=16;
	__static(CacheStyle,
	['_scaleInfo',function(){return this._scaleInfo=new Point();}
	]);
	return CacheStyle;
})()


//class laya.display.css.SpriteStyle
var SpriteStyle=(function(){
	function SpriteStyle(){
		//this.scaleX=NaN;
		//this.scaleY=NaN;
		//this.skewX=NaN;
		//this.skewY=NaN;
		//this.pivotX=NaN;
		//this.pivotY=NaN;
		//this.rotation=NaN;
		//this.alpha=NaN;
		//this.scrollRect=null;
		//this.viewport=null;
		//this.hitArea=null;
		//this.dragging=null;
		//this.blendMode=null;
		this.reset();
	}

	__class(SpriteStyle,'laya.display.css.SpriteStyle');
	var __proto=SpriteStyle.prototype;
	/**
	*重置，方便下次复用
	*/
	__proto.reset=function(){
		this.scaleX=this.scaleY=1;
		this.skewX=this.skewY=0;
		this.pivotX=this.pivotY=this.rotation=0;
		this.alpha=1;
		if(this.scrollRect)this.scrollRect.recover();
		this.scrollRect=null;
		if(this.viewport)this.viewport.recover();
		this.viewport=null;
		this.hitArea=null;
		this.dragging=null;
		this.blendMode=null;
		return this
	}

	/**
	*回收
	*/
	__proto.recover=function(){
		if (this===SpriteStyle.EMPTY)return;
		Pool.recover("SpriteStyle",this.reset());
	}

	SpriteStyle.create=function(){
		return Pool.getItemByClass("SpriteStyle",SpriteStyle);
	}

	SpriteStyle.EMPTY=new SpriteStyle();
	return SpriteStyle;
})()


//class laya.display.GraphicsBounds
var GraphicsBounds=(function(){
	function GraphicsBounds(){
		/**@private */
		//this._temp=null;
		/**@private */
		//this._bounds=null;
		/**@private */
		//this._rstBoundPoints=null;
		/**@private */
		this._cacheBoundsType=false;
		/**@private */
		//this._graphics=null;
	}

	__class(GraphicsBounds,'laya.display.GraphicsBounds');
	var __proto=GraphicsBounds.prototype;
	/**
	*销毁
	*/
	__proto.destroy=function(){
		this._graphics=null;
		this._cacheBoundsType=false;
		if (this._temp)this._temp.length=0;
		if (this._rstBoundPoints)this._rstBoundPoints.length=0;
		if (this._bounds)this._bounds.recover();
		this._bounds=null;
		Pool.recover("GraphicsBounds",this);
	}

	/**
	*重置数据
	*/
	__proto.reset=function(){
		this._temp && (this._temp.length=0);
	}

	/**
	*获取位置及宽高信息矩阵(比较耗CPU，频繁使用会造成卡顿，尽量少用)。
	*@param realSize （可选）使用图片的真实大小，默认为false
	*@return 位置与宽高组成的 一个 Rectangle 对象。
	*/
	__proto.getBounds=function(realSize){
		(realSize===void 0)&& (realSize=false);
		if (!this._bounds || !this._temp || this._temp.length < 1 || realSize !=this._cacheBoundsType){
			this._bounds=Rectangle._getWrapRec(this.getBoundPoints(realSize),this._bounds)
		}
		this._cacheBoundsType=realSize;
		return this._bounds;
	}

	/**
	*@private
	*@param realSize （可选）使用图片的真实大小，默认为false
	*获取端点列表。
	*/
	__proto.getBoundPoints=function(realSize){
		(realSize===void 0)&& (realSize=false);
		if (!this._temp || this._temp.length < 1 || realSize !=this._cacheBoundsType)
			this._temp=this._getCmdPoints(realSize);
		this._cacheBoundsType=realSize;
		return this._rstBoundPoints=Utils.copyArray(this._rstBoundPoints,this._temp);
	}

	__proto._getCmdPoints=function(realSize){
		(realSize===void 0)&& (realSize=false);
		var context=Render._context;
		var cmds=this._graphics.cmds;
		var rst;
		rst=this._temp || (this._temp=[]);
		rst.length=0;
		if (!cmds && this._graphics._one !=null){
			GraphicsBounds._tempCmds.length=0;
			GraphicsBounds._tempCmds.push(this._graphics._one);
			cmds=GraphicsBounds._tempCmds;
		}
		if (!cmds)return rst;
		var matrixs=GraphicsBounds._tempMatrixArrays;
		matrixs.length=0;
		var tMatrix=GraphicsBounds._initMatrix;
		tMatrix.identity();
		var tempMatrix=GraphicsBounds._tempMatrix;
		var cmd;
		var tex;
		for (var i=0,n=cmds.length;i < n;i++){
			cmd=cmds[i];
			switch (cmd.cmdID){
				case "Alpha":
					matrixs.push(tMatrix);
					tMatrix=tMatrix.clone();
					break ;
				case "Restore":
					tMatrix=matrixs.pop();
					break ;
				case "Scale":
					tempMatrix.identity();
					tempMatrix.translate(-cmd.pivotX,-cmd.pivotY);
					tempMatrix.scale(cmd.scaleX,cmd.scaleY);
					tempMatrix.translate(cmd.pivotX,cmd.pivotY);
					this._switchMatrix(tMatrix,tempMatrix);
					break ;
				case "Rotate":
					tempMatrix.identity();
					tempMatrix.translate(-cmd.pivotX,-cmd.pivotY);
					tempMatrix.rotate(cmd.angle);
					tempMatrix.translate(cmd.pivotX,cmd.pivotY);
					this._switchMatrix(tMatrix,tempMatrix);
					break ;
				case "Translate":
					tempMatrix.identity();
					tempMatrix.translate(cmd.tx,cmd.ty);
					this._switchMatrix(tMatrix,tempMatrix);
					break ;
				case "Transform":
					tempMatrix.identity();
					tempMatrix.translate(-cmd.pivotX,-cmd.pivotY);
					tempMatrix.concat(cmd.matrix);
					tempMatrix.translate(cmd.pivotX,cmd.pivotY);
					this._switchMatrix(tMatrix,tempMatrix);
					break ;
				case "DrawImage":
				case "FillTexture":
					GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,cmd.width,cmd.height),tMatrix);
					break ;
				case "DrawTexture":
					tMatrix.copyTo(tempMatrix);
					if(cmd.matrix)
						tempMatrix.concat(cmd.matrix);
					GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,cmd.width,cmd.height),tempMatrix);
					break ;
				case "DrawImage":
					tex=cmd.texture;
					if (realSize){
						if (cmd.width && cmd.height){
							GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,cmd.width,cmd.height),tMatrix);
							}else {
							GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,tex.width,tex.height),tMatrix);
						}
						}else {
						var wRate=(cmd.width || tex.sourceWidth)/ tex.width;
						var hRate=(cmd.height || tex.sourceHeight)/ tex.height;
						var oWidth=wRate *tex.sourceWidth;
						var oHeight=hRate *tex.sourceHeight;
						var offX=tex.offsetX > 0 ? tex.offsetX :0;
						var offY=tex.offsetY > 0 ? tex.offsetY :0;
						offX *=wRate;
						offY *=hRate;
						GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x-offX,cmd.y-offY,oWidth,oHeight),tMatrix);
					}
					break ;
				case "FillTexture":
					if (cmd.width && cmd.height){
						GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,cmd.width,cmd.height),tMatrix);
						}else {
						tex=cmd.texture;
						GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,tex.width,tex.height),tMatrix);
					}
					break ;
				case "DrawTexture":;
					var drawMatrix;
					if (cmd.matrix){
						tMatrix.copyTo(tempMatrix);
						tempMatrix.concat(cmd.matrix);
						drawMatrix=tempMatrix;
						}else {
						drawMatrix=tMatrix;
					}
					if (realSize){
						if (cmd.width && cmd.height){
							GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,cmd.width,cmd.height),drawMatrix);
							}else {
							tex=cmd.texture;
							GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,tex.width,tex.height),drawMatrix);
						}
						}else {
						tex=cmd.texture;
						wRate=(cmd.width || tex.sourceWidth)/ tex.width;
						hRate=(cmd.height || tex.sourceHeight)/ tex.height;
						oWidth=wRate *tex.sourceWidth;
						oHeight=hRate *tex.sourceHeight;
						offX=tex.offsetX > 0 ? tex.offsetX :0;
						offY=tex.offsetY > 0 ? tex.offsetY :0;
						offX *=wRate;
						offY *=hRate;
						GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x-offX,cmd.y-offY,oWidth,oHeight),drawMatrix);
					}
					break ;
				case "DrawRect":
					GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x,cmd.y,cmd.width,cmd.height),tMatrix);
					break ;
				case "DrawCircle":
					GraphicsBounds._addPointArrToRst(rst,Rectangle._getBoundPointS(cmd.x-cmd.radius,cmd.y-cmd.radius,cmd.radius+cmd.radius,cmd.radius+cmd.radius),tMatrix);
					break ;
				case "DrawLine":
					GraphicsBounds._tempPoints.length=0;
					var lineWidth=NaN;
					lineWidth=cmd.lineWidth *0.5;
					if (cmd.fromX==cmd.toX){
						GraphicsBounds._tempPoints.push(cmd.fromX+lineWidth,cmd.fromY,cmd.toX+lineWidth,cmd.toY,cmd.fromX-lineWidth,cmd.fromY,cmd.toX-lineWidth,cmd.toY);
						}else if (cmd.fromY==cmd.toY){
						GraphicsBounds._tempPoints.push(cmd.fromX,cmd.fromY+lineWidth,cmd.toX,cmd.toY+lineWidth,cmd.fromX,cmd.fromY-lineWidth,cmd.toX,cmd.toY-lineWidth);
						}else {
						GraphicsBounds._tempPoints.push(cmd.fromX,cmd.fromY,cmd.toX,cmd.toY);
					}
					GraphicsBounds._addPointArrToRst(rst,GraphicsBounds._tempPoints,tMatrix);
					break ;
				case "DrawCurves":
					GraphicsBounds._addPointArrToRst(rst,Bezier.I.getBezierPoints(cmd.points),tMatrix,cmd.x,cmd.y);
					break ;
				case "DrawLines":
				case "DrawPoly":
					GraphicsBounds._addPointArrToRst(rst,cmd.points,tMatrix,cmd.x,cmd.y);
					break ;
				case "DrawPath":
					GraphicsBounds._addPointArrToRst(rst,this._getPathPoints(cmd.paths),tMatrix,cmd.x,cmd.y);
					break ;
				case "DrawPie":
					GraphicsBounds._addPointArrToRst(rst,this._getPiePoints(cmd.x,cmd.y,cmd.radius,cmd.startAngle,cmd.endAngle),tMatrix);
					break ;
				}
		}
		if (rst.length > 200){
			rst=Utils.copyArray(rst,Rectangle._getWrapRec(rst)._getBoundPoints());
		}else if (rst.length > 8)
		rst=GrahamScan.scanPList(rst);
		return rst;
	}

	__proto._switchMatrix=function(tMatix,tempMatrix){
		tempMatrix.concat(tMatix);
		tempMatrix.copyTo(tMatix);
	}

	__proto._getPiePoints=function(x,y,radius,startAngle,endAngle){
		var rst=GraphicsBounds._tempPoints;
		GraphicsBounds._tempPoints.length=0;
		rst.push(x,y);
		var dP=Math.PI / 10;
		var i=NaN;
		for (i=startAngle;i < endAngle;i+=dP){
			rst.push(x+radius *Math.cos(i),y+radius *Math.sin(i));
		}
		if (endAngle !=i){
			rst.push(x+radius *Math.cos(endAngle),y+radius *Math.sin(endAngle));
		}
		return rst;
	}

	__proto._getPathPoints=function(paths){
		var i=0,len=0;
		var rst=GraphicsBounds._tempPoints;
		rst.length=0;
		len=paths.length;
		var tCMD;
		for (i=0;i < len;i++){
			tCMD=paths[i];
			if (tCMD.length > 1){
				rst.push(tCMD[1],tCMD[2]);
				if (tCMD.length > 3){
					rst.push(tCMD[3],tCMD[4]);
				}
			}
		}
		return rst;
	}

	GraphicsBounds.create=function(){
		return Pool.getItemByClass("GraphicsBounds",GraphicsBounds);
	}

	GraphicsBounds._addPointArrToRst=function(rst,points,matrix,dx,dy){
		(dx===void 0)&& (dx=0);
		(dy===void 0)&& (dy=0);
		var i=0,len=0;
		len=points.length;
		for (i=0;i < len;i+=2){
			GraphicsBounds._addPointToRst(rst,points[i]+dx,points[i+1]+dy,matrix);
		}
	}

	GraphicsBounds._addPointToRst=function(rst,x,y,matrix){
		var _tempPoint=Point.TEMP;
		_tempPoint.setTo(x ? x :0,y ? y :0);
		matrix.transformPoint(_tempPoint);
		rst.push(_tempPoint.x,_tempPoint.y);
	}

	GraphicsBounds._tempPoints=[];
	GraphicsBounds._tempMatrixArrays=[];
	GraphicsBounds._tempCmds=[];
	__static(GraphicsBounds,
	['_tempMatrix',function(){return this._tempMatrix=new Matrix();},'_initMatrix',function(){return this._initMatrix=new Matrix();}
	]);
	return GraphicsBounds;
})()


//class laya.display.SpriteConst
var SpriteConst=(function(){
	function SpriteConst(){}
	__class(SpriteConst,'laya.display.SpriteConst');
	SpriteConst.POSRENDERTYPE=0;
	SpriteConst.POSBUFFERBEGIN=1;
	SpriteConst.POSBUFFEREND=2;
	SpriteConst.POSFRAMECOUNT=3;
	SpriteConst.POSREPAINT=4;
	SpriteConst.POSVISIBLE_NATIVE=5;
	SpriteConst.POSX=6;
	SpriteConst.POSY=7;
	SpriteConst.POSPIVOTX=8;
	SpriteConst.POSPIVOTY=9;
	SpriteConst.POSSCALEX=10;
	SpriteConst.POSSCALEY=11;
	SpriteConst.POSSKEWX=12;
	SpriteConst.POSSKEWY=13;
	SpriteConst.POSROTATION=14;
	SpriteConst.POSTRANSFORM_FLAG=15;
	SpriteConst.POSMATRIX=16;
	SpriteConst.POSCOLOR=22;
	SpriteConst.POSGRAPICS=23;
	SpriteConst.POSSIM_TEXTURE_ID=24;
	SpriteConst.POSSIM_TEXTURE_DATA=25;
	SpriteConst.POSLAYAGL3D=26;
	SpriteConst.POSCUSTOM=27;
	SpriteConst.POSCLIP=28;
	SpriteConst.POSCLIP_NEG_POS=32;
	SpriteConst.POSCOLORFILTER_COLOR=34;
	SpriteConst.POSCOLORFILTER_ALPHA=50;
	SpriteConst.POSCALLBACK_OBJ_ID=54;
	SpriteConst.POSCUSTOM_CALLBACK_FUN_ID=55;
	SpriteConst.POSCANVAS_CALLBACK_FUN_ID=56;
	SpriteConst.POSCANVAS_CALLBACK_END_FUN_ID=57;
	SpriteConst.POSCANVAS_BEGIN_CMD_ID=58;
	SpriteConst.POSCANVAS_END_CMD_ID=59;
	SpriteConst.POSCANVAS_DRAW_TARGET_CMD_ID=60;
	SpriteConst.POSCANVAS_DRAW_TARGET_PARAM_ID=61;
	SpriteConst.POSLAYA3D_FUN_ID=62;
	SpriteConst.POSCACHE_CANVAS_SKIP_PAINT_FLAG=63;
	SpriteConst.POSFILTER_BEGIN_CMD_ID=64;
	SpriteConst.POSFILTER_CALLBACK_FUN_ID=65;
	SpriteConst.POSFILTER_END_CMD_ID=66;
	SpriteConst.POSFILTER_END_CALLBACK_FUN_ID=67;
	SpriteConst.POSGRAPHICS_CALLBACK_FUN_ID=68;
	SpriteConst.POSMASK_CALLBACK_FUN_ID=69;
	SpriteConst.POSMASK_CMD_ID=70;
	SpriteConst.POSBLEND_SRC=71;
	SpriteConst.POSBLEND_DEST=72;
	SpriteConst.POSSIM_RECT_FILL_CMD=73;
	SpriteConst.POSSIM_RECT_FILL_DATA=74;
	SpriteConst.POSSIM_RECT_STROKE_CMD=75;
	SpriteConst.POSSIM_RECT_STROKE_DATA=76;
	SpriteConst.POSSIZE=77;
	SpriteConst.ALPHA=0x01;
	SpriteConst.TRANSFORM=0x02;
	SpriteConst.BLEND=0x04;
	SpriteConst.CANVAS=0x08;
	SpriteConst.FILTERS=0x10;
	SpriteConst.MASK=0x20;
	SpriteConst.CLIP=0x40;
	SpriteConst.STYLE=0x80;
	SpriteConst.TEXTURE=0x100;
	SpriteConst.GRAPHICS=0x200;
	SpriteConst.LAYAGL3D=0x400;
	SpriteConst.CUSTOM=0x800;
	SpriteConst.ONECHILD=0x1000;
	SpriteConst.CHILDS=0x2000;
	SpriteConst.REPAINT_NONE=0;
	SpriteConst.REPAINT_NODE=0x01;
	SpriteConst.REPAINT_CACHE=0x02;
	SpriteConst.REPAINT_ALL=0x03;
	return SpriteConst;
})()


//class laya.events.Event
var Event=(function(){
	function Event(){
		/**事件类型。*/
		//this.type=null;
		/**原生浏览器事件。*/
		//this.nativeEvent=null;
		/**事件目标触发对象。*/
		//this.target=null;
		/**事件当前冒泡对象。*/
		//this.currentTarget=null;
		/**@private */
		//this._stoped=false;
		/**分配给触摸点的唯一标识号（作为 int）。*/
		//this.touchId=0;
		/**键盘值*/
		//this.keyCode=0;
		/**滚轮滑动增量*/
		//this.delta=0;
	}

	__class(Event,'laya.events.Event');
	var __proto=Event.prototype;
	/**
	*设置事件数据。
	*@param type 事件类型。
	*@param currentTarget 事件目标触发对象。
	*@param target 事件当前冒泡对象。
	*@return 返回当前 Event 对象。
	*/
	__proto.setTo=function(type,currentTarget,target){
		this.type=type;
		this.currentTarget=currentTarget;
		this.target=target;
		return this;
	}

	/**
	*阻止对事件流中当前节点的后续节点中的所有事件侦听器进行处理。此方法不会影响当前节点 (currentTarget)中的任何事件侦听器。
	*/
	__proto.stopPropagation=function(){
		this._stoped=true;
	}

	/**鼠标在 Stage 上的 Y 轴坐标*/
	__getset(0,__proto,'stageY',function(){
		return Laya.stage.mouseY;
	});

	/**
	*包含按下或释放的键的字符代码值。字符代码值为英文键盘值。
	*/
	__getset(0,__proto,'charCode',function(){
		return this.nativeEvent.charCode;
	});

	/**
	*触摸点列表。
	*/
	__getset(0,__proto,'touches',function(){
		var arr=this.nativeEvent.touches;
		if (arr){
			var stage=Laya.stage;
			for (var i=0,n=arr.length;i < n;i++){
				var e=arr[i];
				var point=Point.TEMP;
				point.setTo(e.clientX,e.clientY);
				stage._canvasTransform.invertTransformPoint(point);
				stage.transform.invertTransformPoint(point);
				e.stageX=point.x;
				e.stageY=point.y;
			}
		}
		return arr;
	});

	/**
	*表示键在键盘上的位置。这对于区分在键盘上多次出现的键非常有用。<br>
	*例如，您可以根据此属性的值来区分左 Shift 键和右 Shift 键：左 Shift 键的值为 KeyLocation.LEFT，右 Shift 键的值为 KeyLocation.RIGHT。另一个示例是区分标准键盘 (KeyLocation.STANDARD)与数字键盘 (KeyLocation.NUM_PAD)上按下的数字键。
	*/
	__getset(0,__proto,'keyLocation',function(){
		return this.nativeEvent.location || this.nativeEvent.keyLocation;
	});

	/**
	*表示 Ctrl 键是处于活动状态 (true)还是非活动状态 (false)。
	*/
	__getset(0,__proto,'ctrlKey',function(){
		return this.nativeEvent.ctrlKey;
	});

	/**
	*表示 Alt 键是处于活动状态 (true)还是非活动状态 (false)。
	*/
	__getset(0,__proto,'altKey',function(){
		return this.nativeEvent.altKey;
	});

	/**
	*表示 Shift 键是处于活动状态 (true)还是非活动状态 (false)。
	*/
	__getset(0,__proto,'shiftKey',function(){
		return this.nativeEvent.shiftKey;
	});

	/**鼠标在 Stage 上的 X 轴坐标*/
	__getset(0,__proto,'stageX',function(){
		return Laya.stage.mouseX;
	});

	Event.EMPTY=new Event();
	Event.MOUSE_DOWN="mousedown";
	Event.MOUSE_UP="mouseup";
	Event.CLICK="click";
	Event.RIGHT_MOUSE_DOWN="rightmousedown";
	Event.RIGHT_MOUSE_UP="rightmouseup";
	Event.RIGHT_CLICK="rightclick";
	Event.MOUSE_MOVE="mousemove";
	Event.MOUSE_OVER="mouseover";
	Event.MOUSE_OUT="mouseout";
	Event.MOUSE_WHEEL="mousewheel";
	Event.ROLL_OVER="mouseover";
	Event.ROLL_OUT="mouseout";
	Event.DOUBLE_CLICK="doubleclick";
	Event.CHANGE="change";
	Event.CHANGED="changed";
	Event.RESIZE="resize";
	Event.ADDED="added";
	Event.REMOVED="removed";
	Event.DISPLAY="display";
	Event.UNDISPLAY="undisplay";
	Event.ERROR="error";
	Event.COMPLETE="complete";
	Event.LOADED="loaded";
	Event.READY="ready";
	Event.PROGRESS="progress";
	Event.INPUT="input";
	Event.RENDER="render";
	Event.OPEN="open";
	Event.MESSAGE="message";
	Event.CLOSE="close";
	Event.KEY_DOWN="keydown";
	Event.KEY_PRESS="keypress";
	Event.KEY_UP="keyup";
	Event.FRAME="enterframe";
	Event.DRAG_START="dragstart";
	Event.DRAG_MOVE="dragmove";
	Event.DRAG_END="dragend";
	Event.ENTER="enter";
	Event.SELECT="select";
	Event.BLUR="blur";
	Event.FOCUS="focus";
	Event.VISIBILITY_CHANGE="visibilitychange";
	Event.FOCUS_CHANGE="focuschange";
	Event.PLAYED="played";
	Event.PAUSED="paused";
	Event.STOPPED="stopped";
	Event.START="start";
	Event.END="end";
	Event.COMPONENT_ADDED="componentadded";
	Event.COMPONENT_REMOVED="componentremoved";
	Event.RELEASED="released";
	Event.LINK="link";
	Event.LABEL="label";
	Event.FULL_SCREEN_CHANGE="fullscreenchange";
	Event.DEVICE_LOST="devicelost";
	Event.TRANSFORM_CHANGED="transformchanged";
	Event.ANIMATION_CHANGED="animationchanged";
	Event.TRAIL_FILTER_CHANGE="trailfilterchange";
	Event.TRIGGER_ENTER="triggerenter";
	Event.TRIGGER_STAY="triggerstay";
	Event.TRIGGER_EXIT="triggerexit";
	return Event;
})()


//class laya.events.KeyBoardManager
var KeyBoardManager=(function(){
	function KeyBoardManager(){}
	__class(KeyBoardManager,'laya.events.KeyBoardManager');
	KeyBoardManager.__init__=function(){
		KeyBoardManager._addEvent("keydown");
		KeyBoardManager._addEvent("keypress");
		KeyBoardManager._addEvent("keyup");
	}

	KeyBoardManager._addEvent=function(type){
		Browser.document.addEventListener(type,function(e){
			laya.events.KeyBoardManager._dispatch(e,type);
		},true);
	}

	KeyBoardManager._dispatch=function(e,type){
		if (!KeyBoardManager.enabled)return;
		KeyBoardManager._event._stoped=false;
		KeyBoardManager._event.nativeEvent=e;
		KeyBoardManager._event.keyCode=e.keyCode || e.which || e.charCode;
		if (type==="keydown")KeyBoardManager._pressKeys[KeyBoardManager._event.keyCode]=true;
		else if (type==="keyup")KeyBoardManager._pressKeys[KeyBoardManager._event.keyCode]=null;
		var target=(Laya.stage.focus && (Laya.stage.focus.event !=null)&& Laya.stage.focus.displayedInStage)? Laya.stage.focus :Laya.stage;
		var ct=target;
		while (ct){
			ct.event(type,KeyBoardManager._event.setTo(type,ct,target));
			ct=ct.parent;
		}
	}

	KeyBoardManager.hasKeyDown=function(key){
		return KeyBoardManager._pressKeys[key];
	}

	KeyBoardManager._pressKeys={};
	KeyBoardManager.enabled=true;
	__static(KeyBoardManager,
	['_event',function(){return this._event=new Event();}
	]);
	return KeyBoardManager;
})()


//class laya.events.MouseManager
var MouseManager=(function(){
	function MouseManager(){
		/**canvas 上的鼠标X坐标。*/
		this.mouseX=0;
		/**canvas 上的鼠标Y坐标。*/
		this.mouseY=0;
		/**是否禁用除 stage 以外的鼠标事件检测。*/
		this.disableMouseEvent=false;
		/**鼠标按下的时间。单位为毫秒。*/
		this.mouseDownTime=0;
		/**鼠标移动精度。*/
		this.mouseMoveAccuracy=2;
		this._stage=null;
		this._target=null;
		this._lastMoveTimer=0;
		this._isLeftMouse=false;
		this._touchIDs={};
		this._id=1;
		this._tTouchID=0;
		this._event=new Event();
		this._matrix=new Matrix();
		this._point=new Point();
		this._rect=new Rectangle();
		this._prePoint=new Point();
		this._curTouchID=NaN;
	}

	__class(MouseManager,'laya.events.MouseManager');
	var __proto=MouseManager.prototype;
	/**
	*@private
	*初始化。
	*/
	__proto.__init__=function(stage,canvas){
		var _$this=this;
		this._stage=stage;
		var _this=this;
		canvas.oncontextmenu=function (e){
			if (MouseManager.enabled)return false;
		}
		canvas.addEventListener('mousedown',function(e){
			if (MouseManager.enabled){
				if(!Browser.onIE)e.preventDefault();
				_this.mouseDownTime=Browser.now();
				_$this.runEvent(e);
			}
		});
		canvas.addEventListener('mouseup',function(e){
			if (MouseManager.enabled){
				e.preventDefault();
				_this.mouseDownTime=-Browser.now();
				_$this.runEvent(e);
			}
		},true);
		canvas.addEventListener('mousemove',function(e){
			if (MouseManager.enabled){
				e.preventDefault();
				var now=Browser.now();
				if (now-_this._lastMoveTimer < 10)return;
				_this._lastMoveTimer=now;
				_$this.runEvent(e);
			}
		},true);
		canvas.addEventListener("mouseout",function(e){
			if (MouseManager.enabled)_$this.runEvent(e);
		})
		canvas.addEventListener("mouseover",function(e){
			if (MouseManager.enabled)_$this.runEvent(e);
		})
		canvas.addEventListener("touchstart",function(e){
			if (MouseManager.enabled){
				if (!MouseManager._isFirstTouch&&!Input.isInputting)e.preventDefault();
				_this.mouseDownTime=Browser.now();
				_$this.runEvent(e);
			}
		});
		canvas.addEventListener("touchend",function(e){
			if (MouseManager.enabled){
				if (!MouseManager._isFirstTouch&&!Input.isInputting)e.preventDefault();
				MouseManager._isFirstTouch=false;
				_this.mouseDownTime=-Browser.now();
				_$this.runEvent(e);
				}else {
				_$this._curTouchID=NaN;
			}
		},true);
		canvas.addEventListener("touchmove",function(e){
			if (MouseManager.enabled){
				e.preventDefault();
				_$this.runEvent(e);
			}
		},true);
		canvas.addEventListener("touchcancel",function(e){
			if (MouseManager.enabled){
				e.preventDefault();
				_$this.runEvent(e);
				}else {
				_$this._curTouchID=NaN;
			}
		},true);
		canvas.addEventListener('mousewheel',function(e){
			if (MouseManager.enabled)_$this.runEvent(e);
		});
		canvas.addEventListener('DOMMouseScroll',function(e){
			if (MouseManager.enabled)_$this.runEvent(e);
		});
	}

	__proto.initEvent=function(e,nativeEvent){
		var _this=this;
		_this._event._stoped=false;
		_this._event.nativeEvent=nativeEvent || e;
		_this._target=null;
		this._point.setTo(e.pageX || e.clientX,e.pageY || e.clientY);
		this._stage._canvasTransform.invertTransformPoint(this._point);
		_this.mouseX=this._point.x;
		_this.mouseY=this._point.y;
		_this._event.touchId=e.identifier || 0;
		this._tTouchID=_this._event.touchId;
		var evt;
		evt=TouchManager.I._event;
		evt._stoped=false;
		evt.nativeEvent=_this._event.nativeEvent;
		evt.touchId=_this._event.touchId;
	}

	__proto.checkMouseWheel=function(e){
		this._event.delta=e.wheelDelta ? e.wheelDelta *0.025 :-e.detail;
		var _lastOvers=TouchManager.I.getLastOvers();
		for (var i=0,n=_lastOvers.length;i < n;i++){
			var ele=_lastOvers[i];
			ele.event("mousewheel",this._event.setTo("mousewheel",ele,this._target));
		}
	}

	// _stage.event(Event.MOUSE_WHEEL,_event.setTo(Event.MOUSE_WHEEL,_stage,_target));
	__proto.onMouseMove=function(ele){
		TouchManager.I.onMouseMove(ele,this._tTouchID);
	}

	__proto.onMouseDown=function(ele){
		if (Input.isInputting && Laya.stage.focus && Laya.stage.focus["focus"] && !Laya.stage.focus.contains(this._target)){
			var pre_input=Laya.stage.focus['_tf'] || Laya.stage.focus;
			var new_input=ele['_tf'] || ele;
			if ((new_input instanceof laya.display.Input )&& new_input.multiline==pre_input.multiline)
				pre_input['_focusOut']();
			else
			pre_input.focus=false;
		}
		TouchManager.I.onMouseDown(ele,this._tTouchID,this._isLeftMouse);
	}

	__proto.onMouseUp=function(ele){
		TouchManager.I.onMouseUp(ele,this._tTouchID,this._isLeftMouse);
	}

	__proto.check=function(sp,mouseX,mouseY,callBack){
		this._point.setTo(mouseX,mouseY);
		sp.fromParentPoint(this._point);
		mouseX=this._point.x;
		mouseY=this._point.y;
		var scrollRect=sp._style.scrollRect;
		if (scrollRect){
			this._rect.setTo(scrollRect.x,scrollRect.y,scrollRect.width,scrollRect.height);
			if (!this._rect.contains(mouseX,mouseY))return false;
		}
		if (!this.disableMouseEvent){
			if (sp.hitTestPrior && !sp.mouseThrough && !this.hitTest(sp,mouseX,mouseY)){
				return false;
			}
			for (var i=sp._children.length-1;i >-1;i--){
				var child=sp._children[i];
				if (!child.destroyed && child._mouseState > 1 && child._visible){
					if (this.check(child,mouseX,mouseY,callBack))return true;
				}
			}
		};
		var isHit=(sp.hitTestPrior && !sp.mouseThrough && !this.disableMouseEvent)? true :this.hitTest(sp,mouseX,mouseY);
		if (isHit){
			this._target=sp;
			callBack.call(this,sp);
			}else if (callBack===this.onMouseUp && sp===this._stage){
			this._target=this._stage;
			callBack.call(this,this._target);
		}
		return isHit;
	}

	__proto.hitTest=function(sp,mouseX,mouseY){
		var isHit=false;
		if (sp.scrollRect){
			mouseX-=sp._style.scrollRect.x;
			mouseY-=sp._style.scrollRect.y;
		};
		var hitArea=sp._style.hitArea;
		if (hitArea && hitArea._hit){
			return hitArea.contains(mouseX,mouseY);
		}
		if (sp.width > 0 && sp.height > 0 || sp.mouseThrough || hitArea){
			if (!sp.mouseThrough){
				isHit=(hitArea ? hitArea :this._rect.setTo(0,0,sp.width,sp.height)).contains(mouseX,mouseY);
				}else {
				isHit=sp.getGraphicBounds().contains(mouseX,mouseY);
			}
		}
		return isHit;
	}

	/**
	*执行事件处理。
	*/
	__proto.runEvent=function(evt){
		var _this=this;
		var i=0,n=0,touch;
		if (evt.type!=='mousemove')this._prePoint.x=this._prePoint.y=-1000000;
		switch (evt.type){
			case 'mousedown':
				this._touchIDs[0]=this._id++;
				if (!MouseManager._isTouchRespond){
					_this._isLeftMouse=evt.button===0;
					_this.initEvent(evt);
					_this.check(_this._stage,_this.mouseX,_this.mouseY,_this.onMouseDown);
				}else
				MouseManager._isTouchRespond=false;
				break ;
			case 'mouseup':
				_this._isLeftMouse=evt.button===0;
				_this.initEvent(evt);
				_this.check(_this._stage,_this.mouseX,_this.mouseY,_this.onMouseUp);
				break ;
			case 'mousemove':
				if ((Math.abs(this._prePoint.x-evt.clientX)+Math.abs(this._prePoint.y-evt.clientY))>=this.mouseMoveAccuracy){
					this._prePoint.x=evt.clientX;
					this._prePoint.y=evt.clientY;
					_this.initEvent(evt);
					_this.check(_this._stage,_this.mouseX,_this.mouseY,_this.onMouseMove);
				}
				break ;
			case "touchstart":
				MouseManager._isTouchRespond=true;
				_this._isLeftMouse=true;
				var touches=evt.changedTouches;
				for (i=0,n=touches.length;i < n;i++){
					touch=touches[i];
					if (MouseManager.multiTouchEnabled || isNaN(this._curTouchID)){
						this._curTouchID=touch.identifier;
						if (this._id % 200===0)this._touchIDs={};
						this._touchIDs[touch.identifier]=this._id++;
						_this.initEvent(touch,evt);
						_this.check(_this._stage,_this.mouseX,_this.mouseY,_this.onMouseDown);
					}
				}
				break ;
			case "touchend":
			case "touchcancel":
				MouseManager._isTouchRespond=true;
				_this._isLeftMouse=true;
				var touchends=evt.changedTouches;
				for (i=0,n=touchends.length;i < n;i++){
					touch=touchends[i];
					if (MouseManager.multiTouchEnabled || touch.identifier==this._curTouchID){
						this._curTouchID=NaN;
						_this.initEvent(touch,evt);
						var isChecked=false;
						isChecked=_this.check(_this._stage,_this.mouseX,_this.mouseY,_this.onMouseUp);
						if (!isChecked){
							_this.onMouseUp(null);
						}
					}
				}
				break ;
			case "touchmove":;
				var touchemoves=evt.changedTouches;
				for (i=0,n=touchemoves.length;i < n;i++){
					touch=touchemoves[i];
					if (MouseManager.multiTouchEnabled || touch.identifier==this._curTouchID){
						_this.initEvent(touch,evt);
						_this.check(_this._stage,_this.mouseX,_this.mouseY,_this.onMouseMove);
					}
				}
				break ;
			case "wheel":
			case "mousewheel":
			case "DOMMouseScroll":
				_this.checkMouseWheel(evt);
				break ;
			case "mouseout":
				TouchManager.I.stageMouseOut();
				break ;
			case "mouseover":
				_this._stage.event("mouseover",_this._event.setTo("mouseover",_this._stage,_this._stage));
				break ;
			}
	}

	MouseManager.enabled=true;
	MouseManager.multiTouchEnabled=true;
	MouseManager._isTouchRespond=false;
	MouseManager._isFirstTouch=true;
	__static(MouseManager,
	['instance',function(){return this.instance=new MouseManager();}
	]);
	return MouseManager;
})()


//class laya.events.TouchManager
var TouchManager=(function(){
	function TouchManager(){
		/**
		*当前over的touch表
		*/
		this.preOvers=[];
		/**
		*当前down的touch表
		*/
		this.preDowns=[];
		this.preRightDowns=[];
		/**
		*是否启用
		*/
		this.enable=true;
		this._lastClickTime=0;
		this._event=new Event();
	}

	__class(TouchManager,'laya.events.TouchManager');
	var __proto=TouchManager.prototype;
	__proto._clearTempArrs=function(){
		TouchManager._oldArr.length=0;
		TouchManager._newArr.length=0;
		TouchManager._tEleArr.length=0;
	}

	/**
	*从touch表里查找对应touchID的数据
	*@param touchID touch ID
	*@param arr touch表
	*@return
	*
	*/
	__proto.getTouchFromArr=function(touchID,arr){
		var i=0,len=0;
		len=arr.length;
		var tTouchO;
		for (i=0;i < len;i++){
			tTouchO=arr[i];
			if (tTouchO.id==touchID){
				return tTouchO;
			}
		}
		return null;
	}

	/**
	*从touch表里移除一个元素
	*@param touchID touch ID
	*@param arr touch表
	*
	*/
	__proto.removeTouchFromArr=function(touchID,arr){
		var i=0;
		for (i=arr.length-1;i >=0;i--){
			if (arr[i].id==touchID){
				arr.splice(i,1);
			}
		}
	}

	/**
	*创建一个touch数据
	*@param ele 当前的根节点
	*@param touchID touchID
	*@return
	*
	*/
	__proto.createTouchO=function(ele,touchID){
		var rst;
		rst=Pool.getItem("TouchData")|| {};
		rst.id=touchID;
		rst.tar=ele;
		return rst;
	}

	/**
	*处理touchStart
	*@param ele 根节点
	*@param touchID touchID
	*@param isLeft （可选）是否为左键
	*/
	__proto.onMouseDown=function(ele,touchID,isLeft){
		(isLeft===void 0)&& (isLeft=false);
		if (!this.enable)
			return;
		var preO;
		var tO;
		var arrs;
		preO=this.getTouchFromArr(touchID,this.preOvers);
		arrs=this.getEles(ele,null,TouchManager._tEleArr);
		if (!preO){
			tO=this.createTouchO(ele,touchID);
			this.preOvers.push(tO);
			}else {
			preO.tar=ele;
		}
		if (Browser.onMobile)
			this.sendEvents(arrs,"mouseover");
		var preDowns;
		preDowns=isLeft ? this.preDowns :this.preRightDowns;
		preO=this.getTouchFromArr(touchID,preDowns);
		if (!preO){
			tO=this.createTouchO(ele,touchID);
			preDowns.push(tO);
			}else {
			preO.tar=ele;
		}
		this.sendEvents(arrs,isLeft ? "mousedown" :"rightmousedown");
		this._clearTempArrs();
	}

	/**
	*派发事件。
	*@param eles 对象列表。
	*@param type 事件类型。
	*/
	__proto.sendEvents=function(eles,type){
		var i=0,len=0;
		len=eles.length;
		this._event._stoped=false;
		var _target;
		_target=eles[0];
		var tE;
		for (i=0;i < len;i++){
			tE=eles[i];
			if (tE.destroyed)return;
			tE.event(type,this._event.setTo(type,tE,_target));
			if (this._event._stoped)
				break ;
		}
	}

	/**
	*获取对象列表。
	*@param start 起始节点。
	*@param end 结束节点。
	*@param rst 返回值。如果此值不为空，则将其赋值为计算结果，从而避免创建新数组；如果此值为空，则创建新数组返回。
	*@return Array 返回节点列表。
	*/
	__proto.getEles=function(start,end,rst){
		if (!rst){
			rst=[];
			}else {
			rst.length=0;
		}
		while (start && start !=end){
			rst.push(start);
			start=start.parent;
		}
		return rst;
	}

	/**
	*touchMove时处理out事件和over时间。
	*@param eleNew 新的根节点。
	*@param elePre 旧的根节点。
	*@param touchID （可选）touchID，默认为0。
	*/
	__proto.checkMouseOutAndOverOfMove=function(eleNew,elePre,touchID){
		(touchID===void 0)&& (touchID=0);
		if (elePre==eleNew)
			return;
		var tar;
		var arrs;
		var i=0,len=0;
		if (elePre.contains(eleNew)){
			arrs=this.getEles(eleNew,elePre,TouchManager._tEleArr);
			this.sendEvents(arrs,"mouseover");
			}else if (eleNew.contains(elePre)){
			arrs=this.getEles(elePre,eleNew,TouchManager._tEleArr);
			this.sendEvents(arrs,"mouseout");
			}else {
			arrs=TouchManager._tEleArr;
			arrs.length=0;
			var oldArr;
			oldArr=this.getEles(elePre,null,TouchManager._oldArr);
			var newArr;
			newArr=this.getEles(eleNew,null,TouchManager._newArr);
			len=oldArr.length;
			var tIndex=0;
			for (i=0;i < len;i++){
				tar=oldArr[i];
				tIndex=newArr.indexOf(tar);
				if (tIndex >=0){
					newArr.splice(tIndex,newArr.length-tIndex);
					break ;
					}else {
					arrs.push(tar);
				}
			}
			if (arrs.length > 0){
				this.sendEvents(arrs,"mouseout");
			}
			if (newArr.length > 0){
				this.sendEvents(newArr,"mouseover");
			}
		}
	}

	/**
	*处理TouchMove事件
	*@param ele 根节点
	*@param touchID touchID
	*
	*/
	__proto.onMouseMove=function(ele,touchID){
		if (!this.enable)
			return;
		var preO;
		preO=this.getTouchFromArr(touchID,this.preOvers);
		var arrs;
		var tO;
		if (!preO){
			arrs=this.getEles(ele,null,TouchManager._tEleArr);
			this.sendEvents(arrs,"mouseover");
			this.preOvers.push(this.createTouchO(ele,touchID));
			}else {
			this.checkMouseOutAndOverOfMove(ele,preO.tar);
			preO.tar=ele;
			arrs=this.getEles(ele,null,TouchManager._tEleArr);
		}
		this.sendEvents(arrs,"mousemove");
		this._clearTempArrs();
	}

	__proto.getLastOvers=function(){
		TouchManager._tEleArr.length=0;
		if (this.preOvers.length > 0 && this.preOvers[0].tar){
			return this.getEles(this.preOvers[0].tar,null,TouchManager._tEleArr);
		}
		TouchManager._tEleArr.push(Laya.stage);
		return TouchManager._tEleArr;
	}

	__proto.stageMouseOut=function(){
		var lastOvers;
		lastOvers=this.getLastOvers();
		this.preOvers.length=0;
		this.sendEvents(lastOvers,"mouseout");
	}

	/**
	*处理TouchEnd事件
	*@param ele 根节点
	*@param touchID touchID
	*@param isLeft 是否为左键
	*/
	__proto.onMouseUp=function(ele,touchID,isLeft){
		(isLeft===void 0)&& (isLeft=false);
		if (!this.enable)
			return;
		var preO;
		var tO;
		var arrs;
		var oldArr;
		var i=0,len=0;
		var tar;
		var sendArr;
		var onMobile=Browser.onMobile;
		arrs=this.getEles(ele,null,TouchManager._tEleArr);
		this.sendEvents(arrs,isLeft ? "mouseup" :"rightmouseup");
		var preDowns;
		preDowns=isLeft ? this.preDowns :this.preRightDowns;
		preO=this.getTouchFromArr(touchID,preDowns);
		if (!preO){
			}else {
			var isDouble=false;
			var now=Browser.now();
			isDouble=now-this._lastClickTime < 300;
			this._lastClickTime=now;
			if (ele==preO.tar){
				sendArr=arrs;
				}else {
				oldArr=this.getEles(preO.tar,null,TouchManager._oldArr);
				sendArr=TouchManager._newArr;
				sendArr.length=0;
				len=oldArr.length;
				for (i=0;i < len;i++){
					tar=oldArr[i];
					if (arrs.indexOf(tar)>=0){
						sendArr.push(tar);
					}
				}
			}
			if (sendArr.length > 0){
				this.sendEvents(sendArr,isLeft ? "click" :"rightclick");
			}
			if (isLeft && isDouble){
				this.sendEvents(sendArr,"doubleclick");
			}
			this.removeTouchFromArr(touchID,preDowns);
			preO.tar=null;
			Pool.recover("TouchData",preO);
		}
		preO=this.getTouchFromArr(touchID,this.preOvers);
		if (!preO){
			}else {
			if (onMobile){
				sendArr=this.getEles(preO.tar,null,sendArr);
				if (sendArr && sendArr.length > 0){
					this.sendEvents(sendArr,"mouseout");
				}
				this.removeTouchFromArr(touchID,this.preOvers);
				preO.tar=null;
				Pool.recover("TouchData",preO);
			}
		}
		this._clearTempArrs();
	}

	TouchManager._oldArr=[];
	TouchManager._newArr=[];
	TouchManager._tEleArr=[];
	__static(TouchManager,
	['I',function(){return this.I=new TouchManager();}
	]);
	return TouchManager;
})()


//class laya.filters.Filter
var Filter=(function(){
	function Filter(){
		/**@private */
		this._action=null;
		/**@private*/
		this._glRender=null;
	}

	__class(Filter,'laya.filters.Filter');
	var __proto=Filter.prototype;
	Laya.imps(__proto,{"laya.filters.IFilter":true})
	/**@private 滤镜类型。*/
	__getset(0,__proto,'type',function(){return-1});
	Filter.BLUR=0x10;
	Filter.COLOR=0x20;
	Filter.GLOW=0x08;
	Filter._filter=null;
	Filter._recycleScope=null;
	return Filter;
})()


//class laya.filters.ColorFilterAction
var ColorFilterAction=(function(){
	function ColorFilterAction(){
		this.data=null;
	}

	__class(ColorFilterAction,'laya.filters.ColorFilterAction');
	var __proto=ColorFilterAction.prototype;
	/**
	*给指定的对象应用颜色滤镜。
	*@param srcCanvas 需要应用画布对象。
	*@return 应用了滤镜后的画布对象。
	*/
	__proto.apply=function(srcCanvas){
		var canvas=srcCanvas.canvas;
		var ctx=canvas.context;
		if (canvas.width==0 || canvas.height==0)return canvas;
		var imgdata=ctx.getImageData(0,0,canvas.width,canvas.height);
		var data=imgdata.data;
		var nData;
		for (var i=0,n=data.length;i < n;i+=4){
			nData=this.getColor(data[i],data[i+1],data[i+2],data[i+3]);
			if (data[i+3]==0)continue ;
			data[i]=nData[0];
			data[i+1]=nData[1];
			data[i+2]=nData[2];
			data[i+3]=nData[3];
		}
		ctx.putImageData(imgdata,0,0);
		return srcCanvas;
	}

	__proto.getColor=function(red,green,blue,alpha){
		var rst=[];
		if (this.data._mat && this.data._alpha){
			var mat=this.data._mat;
			var tempAlpha=this.data._alpha;
			rst[0]=mat[0] *red+mat[1] *green+mat[2] *blue+mat[3] *alpha+tempAlpha[0];
			rst[1]=mat[4] *red+mat[5] *green+mat[6] *blue+mat[7] *alpha+tempAlpha[1];
			rst[2]=mat[8] *red+mat[9] *green+mat[10] *blue+mat[11] *alpha+tempAlpha[2];
			rst[3]=mat[12] *red+mat[13] *green+mat[14] *blue+mat[15] *alpha+tempAlpha[3];
		}
		return rst;
	}

	return ColorFilterAction;
})()


//class laya.maths.Bezier
var Bezier=(function(){
	function Bezier(){
		/**@private */
		this._controlPoints=[new Point(),new Point(),new Point()];
		this._calFun=this.getPoint2;
	}

	__class(Bezier,'laya.maths.Bezier');
	var __proto=Bezier.prototype;
	/**@private */
	__proto._switchPoint=function(x,y){
		var tPoint=this._controlPoints.shift();
		tPoint.setTo(x,y);
		this._controlPoints.push(tPoint);
	}

	/**
	*计算二次贝塞尔点。
	*/
	__proto.getPoint2=function(t,rst){
		var p1=this._controlPoints[0];
		var p2=this._controlPoints[1];
		var p3=this._controlPoints[2];
		var lineX=Math.pow((1-t),2)*p1.x+2 *t *(1-t)*p2.x+Math.pow(t,2)*p3.x;
		var lineY=Math.pow((1-t),2)*p1.y+2 *t *(1-t)*p2.y+Math.pow(t,2)*p3.y;
		rst.push(lineX,lineY);
	}

	/**
	*计算三次贝塞尔点
	*/
	__proto.getPoint3=function(t,rst){
		var p1=this._controlPoints[0];
		var p2=this._controlPoints[1];
		var p3=this._controlPoints[2];
		var p4=this._controlPoints[3];
		var lineX=Math.pow((1-t),3)*p1.x+3 *p2.x *t *(1-t)*(1-t)+3 *p3.x *t *t *(1-t)+p4.x *Math.pow(t,3);
		var lineY=Math.pow((1-t),3)*p1.y+3 *p2.y *t *(1-t)*(1-t)+3 *p3.y *t *t *(1-t)+p4.y *Math.pow(t,3);
		rst.push(lineX,lineY);
	}

	/**
	*计算贝塞尔点序列
	*/
	__proto.insertPoints=function(count,rst){
		var i=NaN;
		count=count > 0 ? count :5;
		var dLen=NaN;
		dLen=1 / count;
		for (i=0;i <=1;i+=dLen){
			this._calFun(i,rst);
		}
	}

	/**
	*获取贝塞尔曲线上的点。
	*@param pList 控制点[x0,y0,x1,y1...]
	*@param inSertCount 每次曲线的插值数量
	*/
	__proto.getBezierPoints=function(pList,inSertCount,count){
		(inSertCount===void 0)&& (inSertCount=5);
		(count===void 0)&& (count=2);
		var i=0,len=0;
		len=pList.length;
		if (len < (count+1)*2)return [];
		var rst=[];
		switch (count){
			case 2:
				this._calFun=this.getPoint2;
				break ;
			case 3:
				this._calFun=this.getPoint3;
				break ;
			default :
				return [];
			}
		while (this._controlPoints.length <=count){
			this._controlPoints.push(Point.create());
		}
		for (i=0;i < count *2;i+=2){
			this._switchPoint(pList[i],pList[i+1]);
		}
		for (i=count *2;i < len;i+=2){
			this._switchPoint(pList[i],pList[i+1]);
			if ((i / 2)% count==0)this.insertPoints(inSertCount,rst);
		}
		return rst;
	}

	__static(Bezier,
	['I',function(){return this.I=new Bezier();}
	]);
	return Bezier;
})()


//class laya.maths.GrahamScan
var GrahamScan=(function(){
	function GrahamScan(){}
	__class(GrahamScan,'laya.maths.GrahamScan');
	GrahamScan.multiply=function(p1,p2,p0){
		return ((p1.x-p0.x)*(p2.y-p0.y)-(p2.x-p0.x)*(p1.y-p0.y));
	}

	GrahamScan.dis=function(p1,p2){
		return (p1.x-p2.x)*(p1.x-p2.x)+(p1.y-p2.y)*(p1.y-p2.y);
	}

	GrahamScan._getPoints=function(count,tempUse,rst){
		(tempUse===void 0)&& (tempUse=false);
		if (!GrahamScan._mPointList)GrahamScan._mPointList=[];
		while (GrahamScan._mPointList.length < count)GrahamScan._mPointList.push(new Point());
		if (!rst)rst=[];
		rst.length=0;
		if (tempUse){
			GrahamScan.getFrom(rst,GrahamScan._mPointList,count);
			}else {
			GrahamScan.getFromR(rst,GrahamScan._mPointList,count);
		}
		return rst;
	}

	GrahamScan.getFrom=function(rst,src,count){
		var i=0;
		for (i=0;i < count;i++){
			rst.push(src[i]);
		}
		return rst;
	}

	GrahamScan.getFromR=function(rst,src,count){
		var i=0;
		for (i=0;i < count;i++){
			rst.push(src.pop());
		}
		return rst;
	}

	GrahamScan.pListToPointList=function(pList,tempUse){
		(tempUse===void 0)&& (tempUse=false);
		var i=0,len=pList.length / 2,rst=GrahamScan._getPoints(len,tempUse,GrahamScan._tempPointList);
		for (i=0;i < len;i++){
			rst[i].setTo(pList[i+i],pList[i+i+1]);
		}
		return rst;
	}

	GrahamScan.pointListToPlist=function(pointList){
		var i=0,len=pointList.length,rst=GrahamScan._temPList,tPoint;
		rst.length=0;
		for (i=0;i < len;i++){
			tPoint=pointList[i];
			rst.push(tPoint.x,tPoint.y);
		}
		return rst;
	}

	GrahamScan.scanPList=function(pList){
		return Utils.copyArray(pList,GrahamScan.pointListToPlist(GrahamScan.scan(GrahamScan.pListToPointList(pList,true))));
	}

	GrahamScan.scan=function(PointSet){
		var i=0,j=0,k=0,top=2,tmp,n=PointSet.length,ch;
		var _tmpDic={};
		var key;
		ch=GrahamScan._temArr;
		ch.length=0;
		n=PointSet.length;
		for (i=n-1;i >=0;i--){
			tmp=PointSet[i];
			key=tmp.x+"_"+tmp.y;
			if (!_tmpDic.hasOwnProperty(key)){
				_tmpDic[key]=true;
				ch.push(tmp);
			}
		}
		n=ch.length;
		Utils.copyArray(PointSet,ch);
		for (i=1;i < n;i++)
		if ((PointSet[i].y < PointSet[k].y)|| ((PointSet[i].y==PointSet[k].y)&& (PointSet[i].x < PointSet[k].x)))
			k=i;
		tmp=PointSet[0];
		PointSet[0]=PointSet[k];
		PointSet[k]=tmp;
		for (i=1;i < n-1;i++){
			k=i;
			for (j=i+1;j < n;j++)
			if ((GrahamScan.multiply(PointSet[j],PointSet[k],PointSet[0])> 0)|| ((GrahamScan.multiply(PointSet[j],PointSet[k],PointSet[0])==0)&& (GrahamScan.dis(PointSet[0],PointSet[j])< GrahamScan.dis(PointSet[0],PointSet[k]))))
				k=j;
			tmp=PointSet[i];
			PointSet[i]=PointSet[k];
			PointSet[k]=tmp;
		}
		ch=GrahamScan._temArr;
		ch.length=0;
		if (PointSet.length < 3){
			return Utils.copyArray(ch,PointSet);
		}
		ch.push(PointSet[0],PointSet[1],PointSet[2]);
		for (i=3;i < n;i++){
			while (ch.length >=2 && GrahamScan.multiply(PointSet[i],ch[ch.length-1],ch[ch.length-2])>=0)ch.pop();
			PointSet[i] && ch.push(PointSet[i]);
		}
		return ch;
	}

	GrahamScan._mPointList=null;
	GrahamScan._tempPointList=[];
	GrahamScan._temPList=[];
	GrahamScan._temArr=[];
	return GrahamScan;
})()


//class laya.maths.MathUtil
var MathUtil=(function(){
	function MathUtil(){}
	__class(MathUtil,'laya.maths.MathUtil');
	MathUtil.subtractVector3=function(l,r,o){
		o[0]=l[0]-r[0];
		o[1]=l[1]-r[1];
		o[2]=l[2]-r[2];
	}

	MathUtil.lerp=function(left,right,amount){
		return left *(1-amount)+right *amount;
	}

	MathUtil.scaleVector3=function(f,b,e){
		e[0]=f[0] *b;
		e[1]=f[1] *b;
		e[2]=f[2] *b;
	}

	MathUtil.lerpVector3=function(l,r,t,o){
		var ax=l[0],ay=l[1],az=l[2];
		o[0]=ax+t *(r[0]-ax);
		o[1]=ay+t *(r[1]-ay);
		o[2]=az+t *(r[2]-az);
	}

	MathUtil.lerpVector4=function(l,r,t,o){
		var ax=l[0],ay=l[1],az=l[2],aw=l[3];
		o[0]=ax+t *(r[0]-ax);
		o[1]=ay+t *(r[1]-ay);
		o[2]=az+t *(r[2]-az);
		o[3]=aw+t *(r[3]-aw);
	}

	MathUtil.slerpQuaternionArray=function(a,Offset1,b,Offset2,t,out,Offset3){
		var ax=a[Offset1+0],ay=a[Offset1+1],az=a[Offset1+2],aw=a[Offset1+3],bx=b[Offset2+0],by=b[Offset2+1],bz=b[Offset2+2],bw=b[Offset2+3];
		var omega,cosom,sinom,scale0,scale1;
		cosom=ax *bx+ay *by+az *bz+aw *bw;
		if (cosom < 0.0){
			cosom=-cosom;
			bx=-bx;
			by=-by;
			bz=-bz;
			bw=-bw;
		}
		if ((1.0-cosom)> 0.000001){
			omega=Math.acos(cosom);
			sinom=Math.sin(omega);
			scale0=Math.sin((1.0-t)*omega)/ sinom;
			scale1=Math.sin(t *omega)/ sinom;
			}else {
			scale0=1.0-t;
			scale1=t;
		}
		out[Offset3+0]=scale0 *ax+scale1 *bx;
		out[Offset3+1]=scale0 *ay+scale1 *by;
		out[Offset3+2]=scale0 *az+scale1 *bz;
		out[Offset3+3]=scale0 *aw+scale1 *bw;
		return out;
	}

	MathUtil.getRotation=function(x0,y0,x1,y1){
		return Math.atan2(y1-y0,x1-x0)/ Math.PI *180;
	}

	MathUtil.sortBigFirst=function(a,b){
		if (a==b)return 0;
		return b > a ? 1 :-1;
	}

	MathUtil.sortSmallFirst=function(a,b){
		if (a==b)return 0;
		return b > a ?-1 :1;
	}

	MathUtil.sortNumBigFirst=function(a,b){
		return parseFloat(b)-parseFloat(a);
	}

	MathUtil.sortNumSmallFirst=function(a,b){
		return parseFloat(a)-parseFloat(b);
	}

	MathUtil.sortByKey=function(key,bigFirst,forceNum){
		(bigFirst===void 0)&& (bigFirst=false);
		(forceNum===void 0)&& (forceNum=true);
		var _sortFun;
		if (bigFirst){
			_sortFun=forceNum ? MathUtil.sortNumBigFirst :MathUtil.sortBigFirst;
			}else {
			_sortFun=forceNum ? MathUtil.sortNumSmallFirst :MathUtil.sortSmallFirst;
		}
		return function (a,b){
			return _sortFun(a[key],b[key]);
		}
	}

	return MathUtil;
})()


//class laya.maths.Matrix
var Matrix=(function(){
	function Matrix(a,b,c,d,tx,ty,nums){
		/**缩放或旋转图像时影响像素沿 x 轴定位的值。*/
		//this.a=NaN;
		/**旋转或倾斜图像时影响像素沿 y 轴定位的值。*/
		//this.b=NaN;
		/**旋转或倾斜图像时影响像素沿 x 轴定位的值。*/
		//this.c=NaN;
		/**缩放或旋转图像时影响像素沿 y 轴定位的值。*/
		//this.d=NaN;
		/**沿 x 轴平移每个点的距离。*/
		//this.tx=NaN;
		/**沿 y 轴平移每个点的距离。*/
		//this.ty=NaN;
		/**@private 是否有旋转缩放操作*/
		this._bTransform=false;
		(a===void 0)&& (a=1);
		(b===void 0)&& (b=0);
		(c===void 0)&& (c=0);
		(d===void 0)&& (d=1);
		(tx===void 0)&& (tx=0);
		(ty===void 0)&& (ty=0);
		(nums===void 0)&& (nums=0);
		if (Matrix._createFun !=null){
			return Matrix._createFun(a,b,c,d,tx,ty,nums);
		}
		this.a=a;
		this.b=b;
		this.c=c;
		this.d=d;
		this.tx=tx;
		this.ty=ty;
		this._checkTransform();
	}

	__class(Matrix,'laya.maths.Matrix');
	var __proto=Matrix.prototype;
	/**
	*将本矩阵设置为单位矩阵。
	*@return 返回当前矩形。
	*/
	__proto.identity=function(){
		this.a=this.d=1;
		this.b=this.tx=this.ty=this.c=0;
		this._bTransform=false;
		return this;
	}

	/**@private */
	__proto._checkTransform=function(){
		return this._bTransform=(this.a!==1 || this.b!==0 || this.c!==0 || this.d!==1);
	}

	/**
	*设置沿 x 、y 轴平移每个点的距离。
	*@param x 沿 x 轴平移每个点的距离。
	*@param y 沿 y 轴平移每个点的距离。
	*@return 返回对象本身
	*/
	__proto.setTranslate=function(x,y){
		this.tx=x;
		this.ty=y;
		return this;
	}

	/**
	*沿 x 和 y 轴平移矩阵，平移的变化量由 x 和 y 参数指定。
	*@param x 沿 x 轴向右移动的量（以像素为单位）。
	*@param y 沿 y 轴向下移动的量（以像素为单位）。
	*@return 返回此矩形对象。
	*/
	__proto.translate=function(x,y){
		this.tx+=x;
		this.ty+=y;
		return this;
	}

	/**
	*对矩阵应用缩放转换。
	*@param x 用于沿 x 轴缩放对象的乘数。
	*@param y 用于沿 y 轴缩放对象的乘数。
	*@return 返回矩阵对象本身
	*/
	__proto.scale=function(x,y){
		this.a *=x;
		this.d *=y;
		this.c *=x;
		this.b *=y;
		this.tx *=x;
		this.ty *=y;
		this._bTransform=true;
		return this;
	}

	/**
	*对 Matrix 对象应用旋转转换。
	*@param angle 以弧度为单位的旋转角度。
	*@return 返回矩阵对象本身
	*/
	__proto.rotate=function(angle){
		var cos=Math.cos(angle);
		var sin=Math.sin(angle);
		var a1=this.a;
		var c1=this.c;
		var tx1=this.tx;
		this.a=a1 *cos-this.b *sin;
		this.b=a1 *sin+this.b *cos;
		this.c=c1 *cos-this.d *sin;
		this.d=c1 *sin+this.d *cos;
		this.tx=tx1 *cos-this.ty *sin;
		this.ty=tx1 *sin+this.ty *cos;
		this._bTransform=true;
		return this;
	}

	/**
	*对 Matrix 对象应用倾斜转换。
	*@param x 沿着 X 轴的 2D 倾斜弧度。
	*@param y 沿着 Y 轴的 2D 倾斜弧度。
	*@return 当前 Matrix 对象。
	*/
	__proto.skew=function(x,y){
		var tanX=Math.tan(x);
		var tanY=Math.tan(y);
		var a1=this.a;
		var b1=this.b;
		this.a+=tanY *this.c;
		this.b+=tanY *this.d;
		this.c+=tanX *a1;
		this.d+=tanX *b1;
		return this;
	}

	/**
	*对指定的点应用当前矩阵的逆转化并返回此点。
	*@param out 待转化的点 Point 对象。
	*@return 返回out
	*/
	__proto.invertTransformPoint=function(out){
		var a1=this.a;
		var b1=this.b;
		var c1=this.c;
		var d1=this.d;
		var tx1=this.tx;
		var n=a1 *d1-b1 *c1;
		var a2=d1 / n;
		var b2=-b1 / n;
		var c2=-c1 / n;
		var d2=a1 / n;
		var tx2=(c1 *this.ty-d1 *tx1)/ n;
		var ty2=-(a1 *this.ty-b1 *tx1)/ n;
		return out.setTo(a2 *out.x+c2 *out.y+tx2,b2 *out.x+d2 *out.y+ty2);
	}

	/**
	*将 Matrix 对象表示的几何转换应用于指定点。
	*@param out 用来设定输出结果的点。
	*@return 返回out
	*/
	__proto.transformPoint=function(out){
		return out.setTo(this.a *out.x+this.c *out.y+this.tx,this.b *out.x+this.d *out.y+this.ty);
	}

	/**
	*将 Matrix 对象表示的几何转换应用于指定点，忽略tx、ty。
	*@param out 用来设定输出结果的点。
	*@return 返回out
	*/
	__proto.transformPointN=function(out){
		return out.setTo(this.a *out.x+this.c *out.y ,this.b *out.x+this.d *out.y);
	}

	/**
	*获取 X 轴缩放值。
	*@return X 轴缩放值。
	*/
	__proto.getScaleX=function(){
		return this.b===0 ? this.a :Math.sqrt(this.a *this.a+this.b *this.b);
	}

	/**
	*获取 Y 轴缩放值。
	*@return Y 轴缩放值。
	*/
	__proto.getScaleY=function(){
		return this.c===0 ? this.d :Math.sqrt(this.c *this.c+this.d *this.d);
	}

	/**
	*执行原始矩阵的逆转换。
	*@return 当前矩阵对象。
	*/
	__proto.invert=function(){
		var a1=this.a;
		var b1=this.b;
		var c1=this.c;
		var d1=this.d;
		var tx1=this.tx;
		var n=a1 *d1-b1 *c1;
		this.a=d1 / n;
		this.b=-b1 / n;
		this.c=-c1 / n;
		this.d=a1 / n;
		this.tx=(c1 *this.ty-d1 *tx1)/ n;
		this.ty=-(a1 *this.ty-b1 *tx1)/ n;
		return this;
	}

	/**
	*将 Matrix 的成员设置为指定值。
	*@param a 缩放或旋转图像时影响像素沿 x 轴定位的值。
	*@param b 旋转或倾斜图像时影响像素沿 y 轴定位的值。
	*@param c 旋转或倾斜图像时影响像素沿 x 轴定位的值。
	*@param d 缩放或旋转图像时影响像素沿 y 轴定位的值。
	*@param tx 沿 x 轴平移每个点的距离。
	*@param ty 沿 y 轴平移每个点的距离。
	*@return 当前矩阵对象。
	*/
	__proto.setTo=function(a,b,c,d,tx,ty){
		this.a=a,this.b=b,this.c=c,this.d=d,this.tx=tx,this.ty=ty;
		return this;
	}

	/**
	*将指定矩阵与当前矩阵连接，从而将这两个矩阵的几何效果有效地结合在一起。
	*@param matrix 要连接到源矩阵的矩阵。
	*@return 当前矩阵。
	*/
	__proto.concat=function(matrix){
		var a=this.a;
		var c=this.c;
		var tx=this.tx;
		this.a=a *matrix.a+this.b *matrix.c;
		this.b=a *matrix.b+this.b *matrix.d;
		this.c=c *matrix.a+this.d *matrix.c;
		this.d=c *matrix.b+this.d *matrix.d;
		this.tx=tx *matrix.a+this.ty *matrix.c+matrix.tx;
		this.ty=tx *matrix.b+this.ty *matrix.d+matrix.ty;
		return this;
	}

	/**
	*@private
	*对矩阵应用缩放转换。反向相乘
	*@param x 用于沿 x 轴缩放对象的乘数。
	*@param y 用于沿 y 轴缩放对象的乘数。
	*/
	__proto.scaleEx=function(x,y){
		var ba=this.a,bb=this.b,bc=this.c,bd=this.d;
		if (bb!==0 || bc!==0){
			this.a=x *ba;
			this.b=x *bb;
			this.c=y *bc;
			this.d=y *bd;
			}else {
			this.a=x *ba;
			this.b=0 *bd;
			this.c=0 *ba;
			this.d=y *bd;
		}
		this._bTransform=true;
	}

	/**
	*@private
	*对 Matrix 对象应用旋转转换。反向相乘
	*@param angle 以弧度为单位的旋转角度。
	*/
	__proto.rotateEx=function(angle){
		var cos=Math.cos(angle);
		var sin=Math.sin(angle);
		var ba=this.a,bb=this.b,bc=this.c,bd=this.d;
		if (bb!==0 || bc!==0){
			this.a=cos *ba+sin *bc;
			this.b=cos *bb+sin *bd;
			this.c=-sin *ba+cos *bc;
			this.d=-sin *bb+cos *bd;
			}else {
			this.a=cos *ba;
			this.b=sin *bd;
			this.c=-sin *ba;
			this.d=cos *bd;
		}
		this._bTransform=true;
	}

	/**
	*返回此 Matrix 对象的副本。
	*@return 与原始实例具有完全相同的属性的新 Matrix 实例。
	*/
	__proto.clone=function(){
		var dec=Matrix.create();
		dec.a=this.a;
		dec.b=this.b;
		dec.c=this.c;
		dec.d=this.d;
		dec.tx=this.tx;
		dec.ty=this.ty;
		dec._bTransform=this._bTransform;
		return dec;
	}

	/**
	*将当前 Matrix 对象中的所有矩阵数据复制到指定的 Matrix 对象中。
	*@param dec 要复制当前矩阵数据的 Matrix 对象。
	*@return 已复制当前矩阵数据的 Matrix 对象。
	*/
	__proto.copyTo=function(dec){
		dec.a=this.a;
		dec.b=this.b;
		dec.c=this.c;
		dec.d=this.d;
		dec.tx=this.tx;
		dec.ty=this.ty;
		dec._bTransform=this._bTransform;
		return dec;
	}

	/**
	*返回列出该 Matrix 对象属性的文本值。
	*@return 一个字符串，它包含 Matrix 对象的属性值：a、b、c、d、tx 和 ty。
	*/
	__proto.toString=function(){
		return this.a+","+this.b+","+this.c+","+this.d+","+this.tx+","+this.ty;
	}

	/**
	*销毁此对象。
	*/
	__proto.destroy=function(){
		this.recover();
	}

	/**
	*回收到对象池，方便复用
	*/
	__proto.recover=function(){
		Pool.recover("Matrix",this.identity());
	}

	Matrix.mul=function(m1,m2,out){
		var aa=m1.a,ab=m1.b,ac=m1.c,ad=m1.d,atx=m1.tx,aty=m1.ty;
		var ba=m2.a,bb=m2.b,bc=m2.c,bd=m2.d,btx=m2.tx,bty=m2.ty;
		if (bb!==0 || bc!==0){
			out.a=aa *ba+ab *bc;
			out.b=aa *bb+ab *bd;
			out.c=ac *ba+ad *bc;
			out.d=ac *bb+ad *bd;
			out.tx=ba *atx+bc *aty+btx;
			out.ty=bb *atx+bd *aty+bty;
			}else {
			out.a=aa *ba;
			out.b=ab *bd;
			out.c=ac *ba;
			out.d=ad *bd;
			out.tx=ba *atx+btx;
			out.ty=bd *aty+bty;
		}
		return out;
	}

	Matrix.mul16=function(m1,m2,out){
		var aa=m1.a,ab=m1.b,ac=m1.c,ad=m1.d,atx=m1.tx,aty=m1.ty;
		var ba=m2.a,bb=m2.b,bc=m2.c,bd=m2.d,btx=m2.tx,bty=m2.ty;
		if (bb!==0 || bc!==0){
			out[0]=aa *ba+ab *bc;
			out[1]=aa *bb+ab *bd;
			out[4]=ac *ba+ad *bc;
			out[5]=ac *bb+ad *bd;
			out[12]=ba *atx+bc *aty+btx;
			out[13]=bb *atx+bd *aty+bty;
			}else {
			out[0]=aa *ba;
			out[1]=ab *bd;
			out[4]=ac *ba;
			out[5]=ad *bd;
			out[12]=ba *atx+btx;
			out[13]=bd *aty+bty;
		}
		return out;
	}

	Matrix.create=function(){
		return Pool.getItemByClass("Matrix",Matrix);
	}

	Matrix.EMPTY=new Matrix();
	Matrix.TEMP=new Matrix();
	Matrix._createFun=null;
	return Matrix;
})()


//class laya.maths.Point
var Point=(function(){
	function Point(x,y){
		/**该点的水平坐标。*/
		//this.x=NaN;
		/**该点的垂直坐标。*/
		//this.y=NaN;
		(x===void 0)&& (x=0);
		(y===void 0)&& (y=0);
		this.x=x;
		this.y=y;
	}

	__class(Point,'laya.maths.Point');
	var __proto=Point.prototype;
	/**
	*将 <code>Point</code> 的成员设置为指定值。
	*@param x 水平坐标。
	*@param y 垂直坐标。
	*@return 当前 Point 对象。
	*/
	__proto.setTo=function(x,y){
		this.x=x;
		this.y=y;
		return this;
	}

	/**
	*重置
	*/
	__proto.reset=function(){
		this.x=this.y=0;
		return this;
	}

	/**
	*回收到对象池，方便复用
	*/
	__proto.recover=function(){
		Pool.recover("Point",this.reset());
	}

	/**
	*计算当前点和目标点(x，y)的距离。
	*@param x 水平坐标。
	*@param y 垂直坐标。
	*@return 返回当前点和目标点之间的距离。
	*/
	__proto.distance=function(x,y){
		return Math.sqrt((this.x-x)*(this.x-x)+(this.y-y)*(this.y-y));
	}

	/**返回包含 x 和 y 坐标的值的字符串。*/
	__proto.toString=function(){
		return this.x+","+this.y;
	}

	/**
	*标准化向量。
	*/
	__proto.normalize=function(){
		var d=Math.sqrt(this.x *this.x+this.y *this.y);
		if (d > 0){
			var id=1.0 / d;
			this.x *=id;
			this.y *=id;
		}
	}

	/**
	*copy point坐标
	*@param point 需要被copy的point
	*/
	__proto.copy=function(point){
		return this.setTo(point.x,point.y);
	}

	Point.create=function(){
		return Pool.getItemByClass("Point",Point);
	}

	Point.TEMP=new Point();
	Point.EMPTY=new Point();
	return Point;
})()


//class laya.maths.Rectangle
var Rectangle=(function(){
	function Rectangle(x,y,width,height){
		/**矩形左上角的 X 轴坐标。*/
		//this.x=NaN;
		/**矩形左上角的 Y 轴坐标。*/
		//this.y=NaN;
		/**矩形的宽度。*/
		//this.width=NaN;
		/**矩形的高度。*/
		//this.height=NaN;
		(x===void 0)&& (x=0);
		(y===void 0)&& (y=0);
		(width===void 0)&& (width=0);
		(height===void 0)&& (height=0);
		this.x=x;
		this.y=y;
		this.width=width;
		this.height=height;
	}

	__class(Rectangle,'laya.maths.Rectangle');
	var __proto=Rectangle.prototype;
	/**
	*将 Rectangle 的属性设置为指定值。
	*@param x x 矩形左上角的 X 轴坐标。
	*@param y x 矩形左上角的 Y 轴坐标。
	*@param width 矩形的宽度。
	*@param height 矩形的高。
	*@return 返回属性值修改后的矩形对象本身。
	*/
	__proto.setTo=function(x,y,width,height){
		this.x=x;
		this.y=y;
		this.width=width;
		this.height=height;
		return this;
	}

	/**
	*重置
	*/
	__proto.reset=function(){
		this.x=this.y=this.width=this.height=0;
		return this;
	}

	/**
	*回收
	*/
	__proto.recover=function(){
		Pool.recover("Rectangle",this.reset());
	}

	/**
	*复制 source 对象的属性值到此矩形对象中。
	*@param sourceRect 源 Rectangle 对象。
	*@return 返回属性值修改后的矩形对象本身。
	*/
	__proto.copyFrom=function(source){
		this.x=source.x;
		this.y=source.y;
		this.width=source.width;
		this.height=source.height;
		return this;
	}

	/**
	*确定由此 Rectangle 对象定义的矩形区域内是否包含指定的点。
	*@param x 点的 X 轴坐标值（水平位置）。
	*@param y 点的 Y 轴坐标值（垂直位置）。
	*@return 如果 Rectangle 对象包含指定的点，则值为 true；否则为 false。
	*/
	__proto.contains=function(x,y){
		if (this.width <=0 || this.height <=0)return false;
		if (x >=this.x && x < this.right){
			if (y >=this.y && y < this.bottom){
				return true;
			}
		}
		return false;
	}

	/**
	*确定在 rect 参数中指定的对象是否与此 Rectangle 对象相交。此方法检查指定的 Rectangle 对象的 x、y、width 和 height 属性，以查看它是否与此 Rectangle 对象相交。
	*@param rect Rectangle 对象。
	*@return 如果传入的矩形对象与此对象相交，则返回 true 值，否则返回 false。
	*/
	__proto.intersects=function(rect){
		return !(rect.x > (this.x+this.width)|| (rect.x+rect.width)< this.x || rect.y > (this.y+this.height)|| (rect.y+rect.height)< this.y);
	}

	/**
	*如果在 rect 参数中指定的 Rectangle 对象与此 Rectangle 对象相交，则返回交集区域作为 Rectangle 对象。如果矩形不相交，则此方法返回null。
	*@param rect 待比较的矩形区域。
	*@param out （可选）待输出的矩形区域。如果为空则创建一个新的。建议：尽量复用对象，减少对象创建消耗。
	*@return 返回相交的矩形区域对象。
	*/
	__proto.intersection=function(rect,out){
		if (!this.intersects(rect))return null;
		out || (out=new Rectangle());
		out.x=Math.max(this.x,rect.x);
		out.y=Math.max(this.y,rect.y);
		out.width=Math.min(this.right,rect.right)-out.x;
		out.height=Math.min(this.bottom,rect.bottom)-out.y;
		return out;
	}

	/**
	*<p>矩形联合，通过填充两个矩形之间的水平和垂直空间，将这两个矩形组合在一起以创建一个新的 Rectangle 对象。</p>
	*<p>注意：union()方法忽略高度或宽度值为 0 的矩形，如：var rect2:Rectangle=new Rectangle(300,300,50,0);</p>
	*@param 要添加到此 Rectangle 对象的 Rectangle 对象。
	*@param out 用于存储输出结果的矩形对象。如果为空，则创建一个新的。建议：尽量复用对象，减少对象创建消耗。Rectangle.TEMP对象用于对象复用。
	*@return 充当两个矩形的联合的新 Rectangle 对象。
	*/
	__proto.union=function(source,out){
		out || (out=new Rectangle());
		this.clone(out);
		if (source.width <=0 || source.height <=0)return out;
		out.addPoint(source.x,source.y);
		out.addPoint(source.right,source.bottom);
		return this;
	}

	/**
	*返回一个 Rectangle 对象，其 x、y、width 和 height 属性的值与当前 Rectangle 对象的对应值相同。
	*@param out （可选）用于存储结果的矩形对象。如果为空，则创建一个新的。建议：尽量复用对象，减少对象创建消耗。。Rectangle.TEMP对象用于对象复用。
	*@return Rectangle 对象，其 x、y、width 和 height 属性的值与当前 Rectangle 对象的对应值相同。
	*/
	__proto.clone=function(out){
		out || (out=new Rectangle());
		out.x=this.x;
		out.y=this.y;
		out.width=this.width;
		out.height=this.height;
		return out;
	}

	/**
	*当前 Rectangle 对象的水平位置 x 和垂直位置 y 以及高度 width 和宽度 height 以逗号连接成的字符串。
	*/
	__proto.toString=function(){
		return this.x+","+this.y+","+this.width+","+this.height;
	}

	/**
	*检测传入的 Rectangle 对象的属性是否与当前 Rectangle 对象的属性 x、y、width、height 属性值都相等。
	*@param rect 待比较的 Rectangle 对象。
	*@return 如果判断的属性都相等，则返回 true ,否则返回 false。
	*/
	__proto.equals=function(rect){
		if (!rect || rect.x!==this.x || rect.y!==this.y || rect.width!==this.width || rect.height!==this.height)return false;
		return true;
	}

	/**
	*<p>为当前矩形对象加一个点，以使当前矩形扩展为包含当前矩形和此点的最小矩形。</p>
	*<p>此方法会修改本对象。</p>
	*@param x 点的 X 坐标。
	*@param y 点的 Y 坐标。
	*@return 返回此 Rectangle 对象。
	*/
	__proto.addPoint=function(x,y){
		this.x > x && (this.width+=this.x-x,this.x=x);
		this.y > y && (this.height+=this.y-y,this.y=y);
		if (this.width < x-this.x)this.width=x-this.x;
		if (this.height < y-this.y)this.height=y-this.y;
		return this;
	}

	/**
	*@private
	*返回代表当前矩形的顶点数据。
	*@return 顶点数据。
	*/
	__proto._getBoundPoints=function(){
		var rst=Rectangle._temB;
		rst.length=0;
		if (this.width==0 || this.height==0)return rst;
		rst.push(this.x,this.y,this.x+this.width,this.y,this.x,this.y+this.height,this.x+this.width,this.y+this.height);
		return rst;
	}

	/**
	*确定此 Rectangle 对象是否为空。
	*@return 如果 Rectangle 对象的宽度或高度小于等于 0，则返回 true 值，否则返回 false。
	*/
	__proto.isEmpty=function(){
		if (this.width <=0 || this.height <=0)return true;
		return false;
	}

	/**此矩形右侧的 X 轴坐标。 x 和 width 属性的和。*/
	__getset(0,__proto,'right',function(){
		return this.x+this.width;
	});

	/**此矩形底端的 Y 轴坐标。y 和 height 属性的和。*/
	__getset(0,__proto,'bottom',function(){
		return this.y+this.height;
	});

	Rectangle.create=function(){
		return Pool.getItemByClass("Rectangle",Rectangle);
	}

	Rectangle._getBoundPointS=function(x,y,width,height){
		var rst=Rectangle._temA;
		rst.length=0;
		if (width==0 || height==0)return rst;
		rst.push(x,y,x+width,y,x,y+height,x+width,y+height);
		return rst;
	}

	Rectangle._getWrapRec=function(pointList,rst){
		if (!pointList || pointList.length < 1)return rst ? rst.setTo(0,0,0,0):Rectangle.TEMP.setTo(0,0,0,0);
		rst=rst ? rst :laya.maths.Rectangle.create();
		var i,len=pointList.length,minX,maxX,minY,maxY,tPoint=Point.TEMP;
		minX=minY=99999;
		maxX=maxY=-minX;
		for (i=0;i < len;i+=2){
			tPoint.x=pointList[i];
			tPoint.y=pointList[i+1];
			minX=minX < tPoint.x ? minX :tPoint.x;
			minY=minY < tPoint.y ? minY :tPoint.y;
			maxX=maxX > tPoint.x ? maxX :tPoint.x;
			maxY=maxY > tPoint.y ? maxY :tPoint.y;
		}
		return rst.setTo(minX,minY,maxX-minX,maxY-minY);
	}

	Rectangle.EMPTY=new Rectangle();
	Rectangle.TEMP=new Rectangle();
	Rectangle._temB=[];
	Rectangle._temA=[];
	return Rectangle;
})()


//class laya.media.SoundManager
var SoundManager=(function(){
	function SoundManager(){}
	__class(SoundManager,'laya.media.SoundManager');
	__getset(1,SoundManager,'useAudioMusic',function(){
		return SoundManager._useAudioMusic;
		},function(value){
		SoundManager._useAudioMusic=value;
		if (value){
			SoundManager._musicClass=AudioSound;
			}else{
			SoundManager._musicClass=null;
		}
	});

	/**
	*失去焦点后是否自动停止背景音乐。
	*@param v Boolean 失去焦点后是否自动停止背景音乐。
	*
	*/
	/**
	*失去焦点后是否自动停止背景音乐。
	*/
	__getset(1,SoundManager,'autoStopMusic',function(){
		return SoundManager._autoStopMusic;
		},function(v){
		Laya.stage.off("blur",null,SoundManager._stageOnBlur);
		Laya.stage.off("focus",null,SoundManager._stageOnFocus);
		Laya.stage.off("visibilitychange",null,SoundManager._visibilityChange);
		SoundManager._autoStopMusic=v;
		if (v){
			Laya.stage.on("blur",null,SoundManager._stageOnBlur);
			Laya.stage.on("focus",null,SoundManager._stageOnFocus);
			Laya.stage.on("visibilitychange",null,SoundManager._visibilityChange);
		}
	});

	/**
	*背景音乐和所有音效是否静音。
	*/
	__getset(1,SoundManager,'muted',function(){
		return SoundManager._muted;
		},function(value){
		if (value==SoundManager._muted)return;
		if (value){
			SoundManager.stopAllSound();
		}
		SoundManager.musicMuted=value;
		SoundManager._muted=value;
	});

	/**
	*背景音乐（不包括音效）是否静音。
	*/
	__getset(1,SoundManager,'musicMuted',function(){
		return SoundManager._musicMuted;
		},function(value){
		if (value==SoundManager._musicMuted)return;
		if (value){
			if (SoundManager._bgMusic){
				if (SoundManager._musicChannel&&!SoundManager._musicChannel.isStopped){
					SoundManager._musicChannel.pause();
					}else{
					SoundManager._musicChannel=null;
				}
				}else{
				SoundManager._musicChannel=null;
			}
			SoundManager._musicMuted=value;
			}else {
			SoundManager._musicMuted=value;
			if (SoundManager._bgMusic){
				if (SoundManager._musicChannel){
					SoundManager._musicChannel.resume();
				}
			}
		}
	});

	/**
	*所有音效（不包括背景音乐）是否静音。
	*/
	__getset(1,SoundManager,'soundMuted',function(){
		return SoundManager._soundMuted;
		},function(value){
		SoundManager._soundMuted=value;
	});

	SoundManager.__init__=function(){
		var win=Browser.window;
		var supportWebAudio=win["AudioContext"] || win["webkitAudioContext"] || win["mozAudioContext"] ? true :false;
		if (supportWebAudio)WebAudioSound.initWebAudio();
		SoundManager._soundClass=supportWebAudio?WebAudioSound:AudioSound;
		AudioSound._initMusicAudio();
		SoundManager._musicClass=AudioSound;
		return supportWebAudio;
	}

	SoundManager.addChannel=function(channel){
		if (SoundManager._channels.indexOf(channel)>=0)return;
		SoundManager._channels.push(channel);
	}

	SoundManager.removeChannel=function(channel){
		var i=0;
		for (i=SoundManager._channels.length-1;i >=0;i--){
			if (SoundManager._channels[i]==channel){
				SoundManager._channels.splice(i,1);
			}
		}
	}

	SoundManager.disposeSoundLater=function(url){
		SoundManager._lastSoundUsedTimeDic[url]=Browser.now();
		if (!SoundManager._isCheckingDispose){
			SoundManager._isCheckingDispose=true;
			Laya.timer.loop(5000,null,SoundManager._checkDisposeSound);
		}
	}

	SoundManager._checkDisposeSound=function(){
		var key;
		var tTime=Browser.now();
		var hasCheck=false;
		for (key in SoundManager._lastSoundUsedTimeDic){
			if (tTime-SoundManager._lastSoundUsedTimeDic[key]>30000){
				delete SoundManager._lastSoundUsedTimeDic[key];
				SoundManager.disposeSoundIfNotUsed(key);
				}else{
				hasCheck=true;
			}
		}
		if (!hasCheck){
			SoundManager._isCheckingDispose=false;
			Laya.timer.clear(null,SoundManager._checkDisposeSound);
		}
	}

	SoundManager.disposeSoundIfNotUsed=function(url){
		var i=0;
		for (i=SoundManager._channels.length-1;i >=0;i--){
			if (SoundManager._channels[i].url==url){
				return;
			}
		}
		SoundManager.destroySound(url);
	}

	SoundManager._visibilityChange=function(){
		if (Laya.stage.isVisibility){
			SoundManager._stageOnFocus();
			}else {
			SoundManager._stageOnBlur();
		}
	}

	SoundManager._stageOnBlur=function(){
		SoundManager._isActive=false;
		if (SoundManager._musicChannel){
			if (!SoundManager._musicChannel.isStopped){
				SoundManager._blurPaused=true;
				SoundManager._musicChannel.pause();
			}
		}
		SoundManager.stopAllSound();
		Laya.stage.once("mousedown",null,SoundManager._stageOnFocus);
	}

	SoundManager._recoverWebAudio=function(){
		if(WebAudioSound.ctx&&WebAudioSound.ctx.state!="running"&&WebAudioSound.ctx.resume)
			WebAudioSound.ctx.resume();
	}

	SoundManager._stageOnFocus=function(){
		SoundManager._isActive=true;
		SoundManager._recoverWebAudio();
		Laya.stage.off("mousedown",null,SoundManager._stageOnFocus);
		if (SoundManager._blurPaused){
			if (SoundManager._musicChannel && SoundManager._musicChannel.isStopped){
				SoundManager._blurPaused=false;
				SoundManager._musicChannel.resume();
			}
		}
	}

	SoundManager.playSound=function(url,loops,complete,soundClass,startTime){
		(loops===void 0)&& (loops=1);
		(startTime===void 0)&& (startTime=0);
		if (!SoundManager._isActive || !url)return null;
		if (SoundManager._muted)return null;
		SoundManager._recoverWebAudio();
		url=URL.formatURL(url);
		if (url==SoundManager._bgMusic){
			if (SoundManager._musicMuted)return null;
			}else {
			if (Render.isConchApp){
				var ext=Utils.getFileExtension(url);
				if (ext !="wav" && ext !="ogg"){
					alert("The sound only supports wav or ogg format,for optimal performance reason,please refer to the official website document.");
					return null;
				}
			}
			if (SoundManager._soundMuted)return null;
		};
		var tSound;
		if (!Browser.onMiniGame){
			tSound=Laya.loader.getRes(url);
		}
		if (!soundClass)soundClass=SoundManager._soundClass;
		if (!tSound){
			tSound=new soundClass();
			tSound.load(url);
			if (!Browser.onMiniGame){
				Loader.cacheRes(url,tSound);
			}
		};
		var channel;
		channel=tSound.play(startTime,loops);
		if (!channel)return null;
		channel.url=url;
		channel.volume=(url==SoundManager._bgMusic)? SoundManager.musicVolume :SoundManager.soundVolume;
		channel.completeHandler=complete;
		return channel;
	}

	SoundManager.destroySound=function(url){
		var tSound=Laya.loader.getRes(url);
		if (tSound){
			Loader.clearRes(url);
			tSound.dispose();
		}
	}

	SoundManager.playMusic=function(url,loops,complete,startTime){
		(loops===void 0)&& (loops=0);
		(startTime===void 0)&& (startTime=0);
		url=URL.formatURL(url);
		SoundManager._bgMusic=url;
		if (SoundManager._musicChannel)SoundManager._musicChannel.stop();
		return SoundManager._musicChannel=SoundManager.playSound(url,loops,complete,SoundManager._musicClass,startTime);
	}

	SoundManager.stopSound=function(url){
		url=URL.formatURL(url);
		var i=0;
		var channel;
		for (i=SoundManager._channels.length-1;i >=0;i--){
			channel=SoundManager._channels[i];
			if (channel.url==url){
				channel.stop();
			}
		}
	}

	SoundManager.stopAll=function(){
		SoundManager._bgMusic=null;
		var i=0;
		var channel;
		for (i=SoundManager._channels.length-1;i >=0;i--){
			channel=SoundManager._channels[i];
			channel.stop();
		}
	}

	SoundManager.stopAllSound=function(){
		var i=0;
		var channel;
		for (i=SoundManager._channels.length-1;i >=0;i--){
			channel=SoundManager._channels[i];
			if (channel.url !=SoundManager._bgMusic){
				channel.stop();
			}
		}
	}

	SoundManager.stopMusic=function(){
		if (SoundManager._musicChannel)SoundManager._musicChannel.stop();
		SoundManager._bgMusic=null;
	}

	SoundManager.setSoundVolume=function(volume,url){
		if (url){
			url=URL.formatURL(url);
			SoundManager._setVolume(url,volume);
			}else {
			SoundManager.soundVolume=volume;
			var i=0;
			var channel;
			for (i=SoundManager._channels.length-1;i >=0;i--){
				channel=SoundManager._channels[i];
				if (channel.url !=SoundManager._bgMusic){
					channel.volume=volume;
				}
			}
		}
	}

	SoundManager.setMusicVolume=function(volume){
		SoundManager.musicVolume=volume;
		SoundManager._setVolume(SoundManager._bgMusic,volume);
	}

	SoundManager._setVolume=function(url,volume){
		url=URL.formatURL(url);
		var i=0;
		var channel;
		for (i=SoundManager._channels.length-1;i >=0;i--){
			channel=SoundManager._channels[i];
			if (channel.url==url){
				channel.volume=volume;
			}
		}
	}

	SoundManager.musicVolume=1;
	SoundManager.soundVolume=1;
	SoundManager.playbackRate=1;
	SoundManager._useAudioMusic=true;
	SoundManager._muted=false;
	SoundManager._soundMuted=false;
	SoundManager._musicMuted=false;
	SoundManager._bgMusic=null;
	SoundManager._musicChannel=null;
	SoundManager._channels=[];
	SoundManager._autoStopMusic=false;
	SoundManager._blurPaused=false;
	SoundManager._isActive=true;
	SoundManager._soundClass=null;
	SoundManager._musicClass=null;
	SoundManager._lastSoundUsedTimeDic={};
	SoundManager._isCheckingDispose=false;
	SoundManager.autoReleaseSound=true;
	return SoundManager;
})()


//class laya.net.AtlasInfoManager
var AtlasInfoManager=(function(){
	function AtlasInfoManager(){}
	__class(AtlasInfoManager,'laya.net.AtlasInfoManager');
	AtlasInfoManager.enable=function(infoFile,callback){
		Laya.loader.load(infoFile,Handler.create(null,AtlasInfoManager._onInfoLoaded,[callback]),null,"json");
	}

	AtlasInfoManager._onInfoLoaded=function(callback,data){
		var tKey;
		var tPrefix;
		var tArr;
		var i=0,len=0;
		for (tKey in data){
			tArr=data[tKey];
			tPrefix=tArr[0];
			tArr=tArr[1];
			len=tArr.length;
			for (i=0;i < len;i++){
				AtlasInfoManager._fileLoadDic[tPrefix+tArr[i]]=tKey;
			}
		}
		callback && callback.run();
	}

	AtlasInfoManager.getFileLoadPath=function(file){
		return AtlasInfoManager._fileLoadDic[file] || file;
	}

	AtlasInfoManager._fileLoadDic={};
	return AtlasInfoManager;
})()


//class laya.net.LocalStorage
var LocalStorage=(function(){
	var Storage;
	function LocalStorage(){}
	__class(LocalStorage,'laya.net.LocalStorage');
	LocalStorage.__init__=function(){
		if (!LocalStorage._baseClass){
			LocalStorage._baseClass=Storage;
			Storage.init();
		}
		LocalStorage.items=LocalStorage._baseClass.items;
		LocalStorage.support=LocalStorage._baseClass.support;
		return LocalStorage.support;
	}

	LocalStorage.setItem=function(key,value){
		LocalStorage._baseClass.setItem(key,value);
	}

	LocalStorage.getItem=function(key){
		return LocalStorage._baseClass.getItem(key);
	}

	LocalStorage.setJSON=function(key,value){
		LocalStorage._baseClass.setJSON(key,value);
	}

	LocalStorage.getJSON=function(key){
		return LocalStorage._baseClass.getJSON(key);
	}

	LocalStorage.removeItem=function(key){
		LocalStorage._baseClass.removeItem(key);
	}

	LocalStorage.clear=function(){
		LocalStorage._baseClass.clear();
	}

	LocalStorage._baseClass=null;
	LocalStorage.items=null;
	LocalStorage.support=false;
	LocalStorage.__init$=function(){
		//class Storage
		Storage=(function(){
			function Storage(){}
			__class(Storage,'');
			Storage.init=function(){
				try{Storage.support=true;Storage.items=window.localStorage;Storage.setItem('laya','1');Storage.removeItem('laya');}catch(e){Storage.support=false;}if(!Storage.support)console.log('LocalStorage is not supprot or browser is private mode.');
			}
			Storage.setItem=function(key,value){
				try {
					Storage.support && Storage.items.setItem(key,value);
					}catch (e){
					console.warn("set localStorage failed",e);
				}
			}
			Storage.getItem=function(key){
				return Storage.support ? Storage.items.getItem(key):null;
			}
			Storage.setJSON=function(key,value){
				try {
					Storage.support && Storage.items.setItem(key,JSON.stringify(value));
					}catch (e){
					console.warn("set localStorage failed",e);
				}
			}
			Storage.getJSON=function(key){
				return JSON.parse(Storage.support ? Storage.items.getItem(key):null);
			}
			Storage.removeItem=function(key){
				Storage.support && Storage.items.removeItem(key);
			}
			Storage.clear=function(){
				Storage.support && Storage.items.clear();
			}
			Storage.items=null;
			Storage.support=false;
			return Storage;
		})()
	}

	return LocalStorage;
})()


//class laya.net.ResourceVersion
var ResourceVersion=(function(){
	function ResourceVersion(){}
	__class(ResourceVersion,'laya.net.ResourceVersion');
	ResourceVersion.enable=function(manifestFile,callback,type){
		(type===void 0)&& (type=2);
		laya.net.ResourceVersion.type=type;
		Laya.loader.load(manifestFile,Handler.create(null,ResourceVersion.onManifestLoaded,[callback]),null,"json");
		URL.customFormat=ResourceVersion.addVersionPrefix;
	}

	ResourceVersion.onManifestLoaded=function(callback,data){
		ResourceVersion.manifest=data;
		callback.run();
		if (!data){
			console.warn("资源版本清单文件不存在，不使用资源版本管理。忽略ERR_FILE_NOT_FOUND错误。");
		}
	}

	ResourceVersion.addVersionPrefix=function(originURL){
		originURL=URL.getAdptedFilePath(originURL);
		if (ResourceVersion.manifest && ResourceVersion.manifest[originURL]){
			if (ResourceVersion.type==2)return ResourceVersion.manifest[originURL];
			return ResourceVersion.manifest[originURL]+"/"+originURL;
		}
		return originURL;
	}

	ResourceVersion.FOLDER_VERSION=1;
	ResourceVersion.FILENAME_VERSION=2;
	ResourceVersion.manifest=null;
	ResourceVersion.type=1;
	return ResourceVersion;
})()


//class laya.net.TTFLoader
var TTFLoader=(function(){
	function TTFLoader(){
		this.fontName=null;
		this.complete=null;
		this.err=null;
		this._fontTxt=null;
		this._url=null;
		this._div=null;
		this._txtWidth=NaN;
		this._http=null;
	}

	__class(TTFLoader,'laya.net.TTFLoader');
	var __proto=TTFLoader.prototype;
	//TODO:coverage
	__proto.load=function(fontPath){
		this._url=fontPath;
		var tArr=fontPath.split(".ttf")[0].split("/");
		this.fontName=tArr[tArr.length-1];
		if (Render.isConchApp){
			this._loadConch();
		}else
		if (Browser.window.FontFace){
			this._loadWithFontFace()
		}
		else {
			this._loadWithCSS();
		}
	}

	//TODO:coverage
	__proto._loadConch=function(){
		this._http=new HttpRequest();
		this._http.on("error",this,this._onErr);
		this._http.on("complete",this,this._onHttpLoaded);
		this._http.send(this._url,null,"get","arraybuffer");
	}

	//TODO:coverage
	__proto._onHttpLoaded=function(data){
		Browser.window["conchTextCanvas"].setFontFaceFromBuffer(this.fontName,data);
		this._clearHttp();
		this._complete();
	}

	//TODO:coverage
	__proto._clearHttp=function(){
		if (this._http){
			this._http.off("error",this,this._onErr);
			this._http.off("complete",this,this._onHttpLoaded);
			this._http=null;
		}
	}

	//TODO:coverage
	__proto._onErr=function(){
		this._clearHttp();
		if (this.err){
			this.err.runWith("fail:"+this._url);
			this.err=null;
		}
	}

	//TODO:coverage
	__proto._complete=function(){
		Laya.systemTimer.clear(this,this._complete);
		Laya.systemTimer.clear(this,this._checkComplete);
		if (this._div && this._div.parentNode){
			this._div.parentNode.removeChild(this._div);
			this._div=null;
		}
		if (this.complete){
			this.complete.runWith(this);
			this.complete=null;
		}
	}

	//TODO:coverage
	__proto._checkComplete=function(){
		if (RunDriver.measureText("LayaTTFFont",this._fontTxt).width !=this._txtWidth){
			this._complete();
		}
	}

	//TODO:coverage
	__proto._loadWithFontFace=function(){
		var fontFace=new Browser.window.FontFace(this.fontName,"url('"+this._url+"')");
		Browser.window.document.fonts.add(fontFace);
		var self=this;
		fontFace.loaded.then((function(){
			self._complete()
		}));
		fontFace.load();
	}

	//TODO:coverage
	__proto._createDiv=function(){
		this._div=Browser.createElement("div");
		this._div.innerHTML="laya";
		var _style=this._div.style;
		_style.fontFamily=this.fontName;
		_style.position="absolute";
		_style.left="-100px";
		_style.top="-100px";
		Browser.document.body.appendChild(this._div);
	}

	//TODO:coverage
	__proto._loadWithCSS=function(){
		var _$this=this;
		var fontStyle=Browser.createElement("style");
		fontStyle.type="text/css";
		Browser.document.body.appendChild(fontStyle);
		fontStyle.textContent="@font-face { font-family:'"+this.fontName+"'; src:url('"+this._url+"');}";
		this._fontTxt="40px "+this.fontName;
		this._txtWidth=RunDriver.measureText("LayaTTFFont",this._fontTxt).width;
		var self=this;
		fontStyle.onload=function (){
			Laya.systemTimer.once(10000,self,_$this._complete);
		};
		Laya.systemTimer.loop(20,this,this._checkComplete);
		this._createDiv();
	}

	TTFLoader._testString="LayaTTFFont";
	return TTFLoader;
})()


//class laya.net.URL
var URL=(function(){
	function URL(url){
		/**@private */
		this._url=null;
		/**@private */
		this._path=null;
		this._url=URL.formatURL(url);
		this._path=URL.getPath(url);
	}

	__class(URL,'laya.net.URL');
	var __proto=URL.prototype;
	/**地址的文件夹路径（不包括文件名）。*/
	__getset(0,__proto,'path',function(){
		return this._path;
	});

	/**格式化后的地址。*/
	__getset(0,__proto,'url',function(){
		return this._url;
	});

	URL.formatURL=function(url){
		if (!url)return "null path";
		if (url.indexOf(":")> 0)return url;
		if (URL.customFormat !=null)url=URL.customFormat(url);
		if (url.indexOf(":")> 0)return url;
		var char1=url.charAt(0);
		if (char1==="."){
			return URL._formatRelativePath(URL.basePath+url);
			}else if (char1==='~'){
			return URL.rootPath+url.substring(1);
			}else if (char1==="d"){
			if (url.indexOf("data:image")===0)return url;
			}else if (char1==="/"){
			return url;
		}
		return URL.basePath+url;
	}

	URL._formatRelativePath=function(value){
		var parts=value.split("/");
		for (var i=0,len=parts.length;i < len;i++){
			if (parts[i]=='..'){
				parts.splice(i-1,2);
				i-=2;
			}
		}
		return parts.join('/');
	}

	URL.getPath=function(url){
		var ofs=url.lastIndexOf('/');
		return ofs > 0 ? url.substr(0,ofs+1):"";
	}

	URL.getFileName=function(url){
		var ofs=url.lastIndexOf('/');
		return ofs > 0 ? url.substr(ofs+1):url;
	}

	URL.getAdptedFilePath=function(url){
		if (!URL.exportSceneToJson || !url)return url;
		var i=0,len=0;
		len=URL._adpteTypeList.length;
		var tArr;
		for (i=0;i < len;i++){
			tArr=URL._adpteTypeList[i];
			url=url.replace(tArr[0],tArr[1]);
		}
		return url;
	}

	URL.version={};
	URL.exportSceneToJson=false;
	URL.basePath="";
	URL.rootPath="";
	URL.customFormat=function(url){
		var newUrl=URL.version[url];
		if (!Render.isConchApp && newUrl)url+="?v="+newUrl;
		return url;
	}

	__static(URL,
	['_adpteTypeList',function(){return this._adpteTypeList=[[".scene3d",".json"],[".scene",".json"],[".taa",".json"],[".prefab",".json"]];}
	]);
	return URL;
})()


//class laya.renders.LayaGLQuickRunner
var LayaGLQuickRunner=(function(){
	function LayaGLQuickRunner(){}
	__class(LayaGLQuickRunner,'laya.renders.LayaGLQuickRunner');
	LayaGLQuickRunner.__init__=function(){
		LayaGLQuickRunner.map[0x01 | 0x02 | 0x200]=LayaGLQuickRunner.alpha_transform_drawLayaGL;
		LayaGLQuickRunner.map[0x01 | 0x200]=LayaGLQuickRunner.alpha_drawLayaGL;
		LayaGLQuickRunner.map[0x02 | 0x200]=LayaGLQuickRunner.transform_drawLayaGL;
		LayaGLQuickRunner.map[0x02 | 0x2000]=LayaGLQuickRunner.transform_drawNodes;
		LayaGLQuickRunner.map[0x01 | 0x02 | 0x100]=LayaGLQuickRunner.alpha_transform_drawTexture;
		LayaGLQuickRunner.map[0x01 | 0x100]=LayaGLQuickRunner.alpha_drawTexture;
		LayaGLQuickRunner.map[0x02 | 0x100]=LayaGLQuickRunner.transform_drawTexture;
		LayaGLQuickRunner.map[0x200 | 0x2000]=LayaGLQuickRunner.drawLayaGL_drawNodes;
	}

	LayaGLQuickRunner.transform_drawTexture=function(sprite,context,x,y){
		var style=sprite._style;
		var tex=sprite.texture;
		context.saveTransform(LayaGLQuickRunner.curMat);
		context.transformByMatrix(sprite.transform,x,y);
		context.drawTexture(tex,-sprite.pivotX,-sprite.pivotY,sprite._width || tex.width,sprite._height || tex.height);
		context.restoreTransform(LayaGLQuickRunner.curMat);
	}

	LayaGLQuickRunner.alpha_drawTexture=function(sprite,context,x,y){
		var style=sprite._style;
		var alpha=NaN;
		var tex=sprite.texture;
		if ((alpha=style.alpha)> 0.01 || sprite._needRepaint()){
			var temp=context.globalAlpha;
			context.globalAlpha *=alpha;
			context.drawTexture(tex,x-style.pivotX,y-style.pivotY,sprite._width || tex.width,sprite._height || tex.height);
			context.globalAlpha=temp;
		}
	}

	LayaGLQuickRunner.alpha_transform_drawTexture=function(sprite,context,x,y){
		var style=sprite._style;
		var alpha=NaN;
		var tex=sprite.texture;
		if ((alpha=style.alpha)> 0.01 || sprite._needRepaint()){
			var temp=context.globalAlpha;
			context.globalAlpha *=alpha;
			context.saveTransform(LayaGLQuickRunner.curMat);
			context.transformByMatrix(sprite.transform,x,y);
			context.drawTexture(tex,-style.pivotX,-style.pivotY,sprite._width || tex.width,sprite._height || tex.height);
			context.restoreTransform(LayaGLQuickRunner.curMat);
			context.globalAlpha=temp;
		}
	}

	LayaGLQuickRunner.alpha_transform_drawLayaGL=function(sprite,context,x,y){
		var style=sprite._style;
		var alpha=NaN;
		if ((alpha=style.alpha)> 0.01 || sprite._needRepaint()){
			var temp=context.globalAlpha;
			context.globalAlpha *=alpha;
			context.saveTransform(LayaGLQuickRunner.curMat);
			context.transformByMatrix(sprite.transform,x,y);
			sprite._graphics && sprite._graphics._render(sprite,context,-style.pivotX,-style.pivotY);
			context.restoreTransform(LayaGLQuickRunner.curMat);
			context.globalAlpha=temp;
		}
	}

	LayaGLQuickRunner.alpha_drawLayaGL=function(sprite,context,x,y){
		var style=sprite._style;
		var alpha=NaN;
		if ((alpha=style.alpha)> 0.01 || sprite._needRepaint()){
			var temp=context.globalAlpha;
			context.globalAlpha *=alpha;
			sprite._graphics && sprite._graphics._render(sprite,context,x-style.pivotX,y-style.pivotY);
			context.globalAlpha=temp;
		}
	}

	LayaGLQuickRunner.transform_drawLayaGL=function(sprite,context,x,y){
		var style=sprite._style;
		context.saveTransform(LayaGLQuickRunner.curMat);
		context.transformByMatrix(sprite.transform,x,y);
		sprite._graphics && sprite._graphics._render(sprite,context,-style.pivotX,-style.pivotY);
		context.restoreTransform(LayaGLQuickRunner.curMat);
	}

	LayaGLQuickRunner.transform_drawNodes=function(sprite,context,x,y){
		var style=sprite._style;
		context.saveTransform(LayaGLQuickRunner.curMat);
		context.transformByMatrix(sprite.transform,x,y);
		x=-style.pivotX;
		y=-style.pivotY;
		var childs=sprite._children,n=childs.length,ele;
		if (style.viewport){
			var rect=style.viewport;
			var left=rect.x;
			var top=rect.y;
			var right=rect.right;
			var bottom=rect.bottom;
			var _x=NaN,_y=NaN;
			for (i=0;i < n;++i){
				if ((ele=childs [i])._visible && ((_x=ele._x)< right && (_x+ele.width)> left && (_y=ele._y)< bottom && (_y+ele.height)> top)){
					ele.render(context,x,y);
				}
			}
			}else {
			for (var i=0;i < n;++i)
			(ele=(childs [i]))._visible && ele.render(context,x,y);
		}
		context.restoreTransform(LayaGLQuickRunner.curMat);
	}

	LayaGLQuickRunner.drawLayaGL_drawNodes=function(sprite,context,x,y){
		var style=sprite._style;
		x=x-style.pivotX;
		y=y-style.pivotY;
		sprite._graphics && sprite._graphics._render(sprite,context,x,y);
		var childs=sprite._children,n=childs.length,ele;
		if (style.viewport){
			var rect=style.viewport;
			var left=rect.x;
			var top=rect.y;
			var right=rect.right;
			var bottom=rect.bottom;
			var _x=NaN,_y=NaN;
			for (i=0;i < n;++i){
				if ((ele=childs [i])._visible && ((_x=ele._x)< right && (_x+ele.width)> left && (_y=ele._y)< bottom && (_y+ele.height)> top)){
					ele.render(context,x,y);
				}
			}
			}else {
			for (var i=0;i < n;++i)
			(ele=(childs [i]))._visible && ele.render(context,x,y);
		}
	}

	LayaGLQuickRunner.map={};
	__static(LayaGLQuickRunner,
	['curMat',function(){return this.curMat=new Matrix();}
	]);
	return LayaGLQuickRunner;
})()


//class laya.renders.Render
var Render=(function(){
	function Render(width,height){
		/**@private */
		this._timeId=0;
		Render._mainCanvas.source.id="layaCanvas";
		Render._mainCanvas.source.width=width;
		Render._mainCanvas.source.height=height;
		Browser.container.appendChild(Render._mainCanvas.source);
		RunDriver.initRender(Render._mainCanvas,width,height);
		Browser.window.requestAnimationFrame(loop);
		function loop (stamp){
			Laya.stage._loop();
			Browser.window.requestAnimationFrame(loop);
		}
		Laya.stage.on("visibilitychange",this,this._onVisibilitychange);
	}

	__class(Render,'laya.renders.Render');
	var __proto=Render.prototype;
	/**@private */
	__proto._onVisibilitychange=function(){
		if (!Laya.stage.isVisibility){
			this._timeId=Browser.window.setInterval(this._enterFrame,1000);
			}else if (this._timeId !=0){
			Browser.window.clearInterval(this._timeId);
		}
	}

	/**@private */
	__proto._enterFrame=function(e){
		Laya.stage._loop();
	}

	/**目前使用的渲染器。*/
	__getset(1,Render,'context',function(){
		return Render._context;
	});

	/**渲染使用的原生画布引用。 */
	__getset(1,Render,'canvas',function(){
		return Render._mainCanvas.source;
	});

	Render._context=null;
	Render._mainCanvas=null;
	Render.isWebGL=false;
	Render.is3DMode=false;
	__static(Render,
	['isConchApp',function(){return this.isConchApp=(window.conch !=null);}
	]);
	return Render;
})()


//class laya.renders.RenderSprite
var RenderSprite=(function(){
	function RenderSprite(type,next){
		/**@private */
		//this._next=null;
		/**@private */
		//this._fun=null;
		if (LayaGLQuickRunner.map[type]){
			this._fun=LayaGLQuickRunner.map[type];
			this._next=RenderSprite.NORENDER;
			return;
		}
		this._next=next || RenderSprite.NORENDER;
		switch (type){
			case 0:
				this._fun=this._no;
				return;
			case 0x01:
				this._fun=this._alpha;
				return;
			case 0x02:
				this._fun=this._transform;
				return;
			case 0x04:
				this._fun=this._blend;
				return;
			case 0x08:
				this._fun=this._canvas;
				return;
			case 0x20:
				this._fun=this._mask;
				return;
			case 0x40:
				this._fun=this._clip;
				return;
			case 0x80:
				this._fun=this._style;
				return;
			case 0x200:
				this._fun=this._graphics;
				return;
			case 0x2000:
				this._fun=this._children;
				return;
			case 0x800:
				this._fun=this._custom;
				return;
			case 0x100:
				this._fun=this._texture;
				return;
			case 0x10:
				this._fun=Filter._filter;
				return;
			case 0x11111:
				this._fun=RenderSprite._initRenderFun;
				return;
			}
		this.onCreate(type);
	}

	__class(RenderSprite,'laya.renders.RenderSprite');
	var __proto=RenderSprite.prototype;
	__proto.onCreate=function(type){}
	__proto._style=function(sprite,context,x,y){
		var style=sprite._style;
		if (style.render !=null)style.render(sprite,context,x,y);
		var next=this._next;
		next._fun.call(next,sprite,context,x,y);
	}

	__proto._no=function(sprite,context,x,y){}
	//TODO:coverage
	__proto._custom=function(sprite,context,x,y){
		sprite.customRender(context,x,y);
		this._next._fun.call(this._next,sprite,context,x-sprite.pivotX,y-sprite.pivotY);
	}

	__proto._clip=function(sprite,context,x,y){
		var next=this._next;
		if (next==RenderSprite.NORENDER)return;
		var r=sprite._style.scrollRect;
		context.save();
		context.clipRect(x,y,r.width,r.height);
		next._fun.call(next,sprite,context,x-r.x,y-r.y);
		context.restore();
	}

	//TODO:coverage
	__proto._blend=function(sprite,context,x,y){
		var style=sprite._style;
		if (style.blendMode){
			context.globalCompositeOperation=style.blendMode;
		};
		var next=this._next;
		next._fun.call(next,sprite,context,x,y);
		context.globalCompositeOperation="source-over";
	}

	//TODO:coverage
	__proto._mask=function(sprite,context,x,y){
		var next=this._next;
		next._fun.call(next,sprite,context,x,y);
		var mask=sprite.mask;
		if (mask){
			context.globalCompositeOperation="destination-in";
			if (mask.numChildren > 0 || !mask.graphics._isOnlyOne()){
				mask.cacheAs="bitmap";
			}
			mask.render(context,x-sprite._style.pivotX,y-sprite._style.pivotY);
		}
		context.globalCompositeOperation="source-over";
	}

	__proto._texture=function(sprite,context,x,y){
		var tex=sprite.texture;
		if(tex._getSource())
			context.drawTexture(tex,x-sprite.pivotX,y-sprite.pivotY,sprite._width || tex.width,sprite._height || tex.height);
		var next=this._next;
		next._fun.call(next,sprite,context,x,y);
	}

	__proto._graphics=function(sprite,context,x,y){
		sprite._graphics && sprite._graphics._render(sprite,context,x-sprite.pivotX,y-sprite.pivotY);
		var next=this._next;
		next._fun.call(next,sprite,context,x,y);
	}

	//TODO:coverage
	__proto._image=function(sprite,context,x,y){
		var style=sprite._style;
		context.drawTexture2(x,y,style.pivotX,style.pivotY,sprite.transform,sprite._graphics._one);
	}

	//TODO:coverage
	__proto._image2=function(sprite,context,x,y){
		var style=sprite._style;
		context.drawTexture2(x,y,style.pivotX,style.pivotY,sprite.transform,sprite._graphics._one);
	}

	//TODO:coverage
	__proto._alpha=function(sprite,context,x,y){
		var style=sprite._style;
		var alpha;
		if ((alpha=style.alpha)> 0.01 || sprite._needRepaint()){
			var temp=context.globalAlpha;
			context.globalAlpha *=alpha;
			var next=this._next;
			next._fun.call(next,sprite,context,x,y);
			context.globalAlpha=temp;
		}
	}

	__proto._transform=function(sprite,context,x,y){
		var transform=sprite.transform,_next=this._next;
		var style=sprite._style;
		if (transform && _next !=RenderSprite.NORENDER){
			context.save();
			context.transform(transform.a,transform.b,transform.c,transform.d,transform.tx+x,transform.ty+y);
			_next._fun.call(_next,sprite,context,0,0);
			context.restore();
		}else
		_next._fun.call(_next,sprite,context,x,y);
	}

	__proto._children=function(sprite,context,x,y){
		var style=sprite._style;
		var childs=sprite._children,n=childs.length,ele;
		x=x-sprite.pivotX;
		y=y-sprite.pivotY;
		if (style.viewport){
			var rect=style.viewport;
			var left=rect.x;
			var top=rect.y;
			var right=rect.right;
			var bottom=rect.bottom;
			var _x=NaN,_y=NaN;
			for (i=0;i < n;++i){
				if ((ele=childs [i])._visible && ((_x=ele._x)< right && (_x+ele.width)> left && (_y=ele._y)< bottom && (_y+ele.height)> top)){
					ele.render(context,x,y);
				}
			}
			}else {
			for (var i=0;i < n;++i)
			(ele=(childs [i]))._visible && ele.render(context,x,y);
		}
	}

	__proto._canvas=function(sprite,context,x,y){
		var _cacheStyle=sprite._cacheStyle;
		var _next=this._next;
		if (!_cacheStyle.enableCanvasRender){
			_next._fun.call(_next,sprite,context,x,y);
			return;
		}
		_cacheStyle.cacheAs==='bitmap' ? (Stat.canvasBitmap++):(Stat.canvasNormal++);
		if (sprite._needRepaint()|| (!_cacheStyle.canvas)){
			this._canvas_repaint(sprite,context,x,y);
			}else {
			var tRec=_cacheStyle.cacheRect;
			context.drawCanvas(_cacheStyle.canvas,x+tRec.x,y+tRec.y,tRec.width,tRec.height);
		}
	}

	__proto._canvas_repaint=function(sprite,context,x,y){
		var _cacheStyle=sprite._cacheStyle;
		var _next=this._next;
		var tx;
		var canvas=_cacheStyle.canvas;
		var left;
		var top;
		var tRec;
		var tCacheType=_cacheStyle.cacheAs;
		var w,h;
		var scaleX,scaleY;
		var scaleInfo;
		scaleInfo=_cacheStyle._calculateCacheRect(sprite,tCacheType,x,y);
		scaleX=scaleInfo.x;
		scaleY=scaleInfo.y;
		tRec=_cacheStyle.cacheRect;
		w=tRec.width *scaleX;
		h=tRec.height *scaleY;
		left=tRec.x;
		top=tRec.y;
		if (Render.isWebGL && tCacheType==='bitmap' && (w > 2048 || h > 2048)){
			console.warn("cache bitmap size larger than 2048,cache ignored");
			_cacheStyle.releaseContext();
			_next._fun.call(_next,sprite,context,x,y);
			return;
		}
		if (!canvas){
			_cacheStyle.createContext();
			canvas=_cacheStyle.canvas;
		}
		tx=canvas.context;
		tx.sprite=sprite;
		(canvas.width !=w || canvas.height !=h)&& canvas.size(w,h);
		if (tCacheType==='bitmap')tx.asBitmap=true;
		else if (tCacheType==='normal')tx.asBitmap=false;
		tx.clear();
		if (tCacheType==='normal'){
			tx.touches=[];
		}
		if (scaleX !=1 || scaleY !=1){
			var ctx=tx;
			ctx.save();
			ctx.scale(scaleX,scaleY);
			_next._fun.call(_next,sprite,tx,-left,-top);
			ctx.restore();
			sprite._applyFilters();
			}else {
			ctx=tx;
			_next._fun.call(_next,sprite,tx,-left,-top);
			sprite._applyFilters();
		}
		if (_cacheStyle.staticCache)_cacheStyle.reCache=false;
		Stat.canvasReCache++;
		context.drawCanvas(canvas,x+left,y+top,tRec.width,tRec.height);
	}

	RenderSprite.__init__=function(){
		LayaGLQuickRunner.__init__();
		var i=0,len=0;
		var initRender;
		initRender=RunDriver.createRenderSprite(0x11111,null);
		len=RenderSprite.renders.length=0x2000 *2;
		for (i=0;i < len;i++)
		RenderSprite.renders[i]=initRender;
		RenderSprite.renders[0]=RunDriver.createRenderSprite(0,null);
		function _initSame (value,o){
			var n=0;
			for (var i=0;i < value.length;i++){
				n |=value[i];
				RenderSprite.renders[n]=o;
			}
		}
	}

	RenderSprite._initRenderFun=function(sprite,context,x,y){
		var type=sprite._renderType;
		var r=RenderSprite.renders[type]=RenderSprite._getTypeRender(type);
		r._fun(sprite,context,x,y);
	}

	RenderSprite._getTypeRender=function(type){
		if (LayaGLQuickRunner.map[type])return RunDriver.createRenderSprite(type,null);
		var rst=null;
		var tType=0x2000;
		while (tType > 0){
			if (tType & type)
				rst=RunDriver.createRenderSprite(tType,rst);
			tType=tType >> 1;
		}
		return rst;
	}

	RenderSprite.INIT=0x11111;
	RenderSprite.renders=[];
	RenderSprite.NORENDER=new RenderSprite(0,null);
	return RenderSprite;
})()


//class laya.resource.Context
var Context=(function(){
	function Context(){
		//this._canvas=null;
	}

	__class(Context,'laya.resource.Context');
	var __proto=Context.prototype;
	//TODO:coverage
	__proto.drawCanvas=function(canvas,x,y,width,height){
		Stat.drawCall++;
		this.drawImage(canvas._source,x,y,width,height);
	}

	//TODO:coverage
	__proto._drawRect=function(x,y,width,height,style){
		Stat.drawCall++;
		style && (this.fillStyle=style);
		this.fillRect(x,y,width,height);
	}

	//TODO:coverage
	__proto.drawText=function(text,x,y,font,color,textAlign){
		Stat.drawCall++;
		if (arguments.length > 3 && font !=null){
			this.font=font;
			this.fillStyle=color;
			this.textAlign=textAlign;
			this.textBaseline="top";
		}
		this.fillText(text,x,y);
	}

	//TODO:coverage
	__proto.fillBorderText=function(text,x,y,font,fillColor,borderColor,lineWidth,textAlign){
		Stat.drawCall++;
		this.font=font;
		this.fillStyle=fillColor;
		this.textBaseline="top";
		this.strokeStyle=borderColor;
		this.lineWidth=lineWidth;
		this.textAlign=textAlign;
		this.strokeText(text,x,y);
		this.fillText(text,x,y);
	}

	//TODO:coverage
	__proto.fillWords=function(words,x,y,font,color){
		font && (this.font=font);
		color && (this.fillStyle=color);
		this.textBaseline="top";
		this.textAlign='left';
		for (var i=0,n=words.length;i < n;i++){
			var a=words[i];
			this.fillText(a.char,a.x+x,a.y+y);
		}
	}

	//TODO:coverage
	__proto.fillBorderWords=function(words,x,y,font,color,borderColor,lineWidth){
		font && (this.font=font);
		color && (this.fillStyle=color);
		this.textBaseline="top";
		this.lineWidth=lineWidth;
		this.textAlign='left';
		this.strokeStyle=borderColor;
		for (var i=0,n=words.length;i < n;i++){
			var a=words[i];
			this.strokeText(a.char,a.x+x,a.y+y);
			this.fillText(a.char,a.x+x,a.y+y);
		}
	}

	//TODO:coverage
	__proto.strokeWord=function(text,x,y,font,color,lineWidth,textAlign){
		Stat.drawCall++;
		if (arguments.length > 3 && font !=null){
			this.font=font;
			this.strokeStyle=color;
			this.lineWidth=lineWidth;
			this.textAlign=textAlign;
			this.textBaseline="top";
		}
		this.strokeText(text,x,y);
	}

	//TODO:coverage
	__proto.setTransformByMatrix=function(value){
		this.setTransform(value.a,value.b,value.c,value.d,value.tx,value.ty);
	}

	//TODO:coverage
	__proto.clipRect=function(x,y,width,height){
		Stat.drawCall++;
		this.beginPath();
		this.rect(x,y,width,height);
		this.clip();
	}

	//TODO:coverage
	__proto.drawTextureWithTransform=function(tex,tx,ty,width,height,m,gx,gy,alpha,blendMode){
		if (!tex._getSource())
			return;
		Stat.drawCall++;
		var alphaChanged=alpha!==1;
		if (alphaChanged){
			var temp=this.globalAlpha;
			this.globalAlpha *=alpha;
		}
		if (blendMode)
			this.globalCompositeOperation=blendMode;
		var uv=tex.uv,w=tex.bitmap._width,h=tex.bitmap._height;
		if (m){
			this.save();
			this.transform(m.a,m.b,m.c,m.d,m.tx+gx,m.ty+gy);
			this.drawImage(tex.bitmap._source,uv[0] *w,uv[1] *h,(uv[2]-uv[0])*w,(uv[5]-uv[3])*h,tx,ty,width,height);
			this.restore();
			}else {
			this.drawImage(tex.bitmap._source,uv[0] *w,uv[1] *h,(uv[2]-uv[0])*w,(uv[5]-uv[3])*h,gx+tx,gy+ty,width,height);
		}
		if (alphaChanged)
			this.globalAlpha=temp;
		if (blendMode)
			this.globalCompositeOperation="source-over";
	}

	//TODO:coverage
	__proto.drawTexture2=function(x,y,pivotX,pivotY,m,args2){
		var tex=args2[0];
		Stat.drawCall++;
		var uv=tex.uv,w=tex.bitmap._width,h=tex.bitmap._height;
		if (m){
			this.save();
			this.transform(m.a,m.b,m.c,m.d,m.tx+x,m.ty+y);
			this.drawImage(tex.bitmap._source,uv[0] *w,uv[1] *h,(uv[2]-uv[0])*w,(uv[5]-uv[3])*h,args2[1]-pivotX,args2[2]-pivotY,args2[3],args2[4]);
			this.restore();
			}else {
			this.drawImage(tex.bitmap._source,uv[0] *w,uv[1] *h,(uv[2]-uv[0])*w,(uv[5]-uv[3])*h,args2[1]-pivotX+x,args2[2]-pivotY+y,args2[3],args2[4]);
		}
	}

	//TODO:coverage
	__proto.fillTexture=function(texture,x,y,width,height,type,offset,other){
		if (!other.pat){
			if (texture.uv !=Texture.DEF_UV){
				var canvas=new HTMLCanvas();
				canvas.getContext('2d');
				canvas.size(texture.width,texture.height);
				canvas.context.drawTexture(texture,0,0,texture.width,texture.height);
				texture=new Texture(canvas);
			}
			other.pat=this.createPattern(texture.bitmap._source,type);
		};
		var oX=x,oY=y;
		var sX=0,sY=0;
		if (offset){
			oX+=offset.x % texture.width;
			oY+=offset.y % texture.height;
			sX-=offset.x % texture.width;
			sY-=offset.y % texture.height;
		}
		this.translate(oX,oY);
		this._drawRect(sX,sY,width,height,other.pat);
		this.translate(-oX,-oY);
	}

	/**@private */
	__proto.flush=function(){
		return 0;
	}

	/**@private */
	__proto.destroy=function(){
		this.canvas.width=this.canvas.height=0;
	}

	/**@private */
	__proto.clear=function(){
		if(!Render.isConchApp)this.clearRect(0,0,Render._mainCanvas.width,Render._mainCanvas.height);
	}

	//TODO:coverage
	__proto.drawTriangle=function(texture,vertices,uvs,index0,index1,index2,matrix,canvasPadding){
		var source=texture.bitmap;
		var textureSource=source._getSource();
		var textureWidth=texture.width;
		var textureHeight=texture.height;
		var sourceWidth=source.width;
		var sourceHeight=source.height;
		var u0=uvs[index0] *sourceWidth;
		var u1=uvs[index1] *sourceWidth;
		var u2=uvs[index2] *sourceWidth;
		var v0=uvs[index0+1] *sourceHeight;
		var v1=uvs[index1+1] *sourceHeight;
		var v2=uvs[index2+1] *sourceHeight;
		var x0=vertices[index0];
		var x1=vertices[index1];
		var x2=vertices[index2];
		var y0=vertices[index0+1];
		var y1=vertices[index1+1];
		var y2=vertices[index2+1];
		if (canvasPadding){
			var paddingX=1;
			var paddingY=1;
			var centerX=(x0+x1+x2)/ 3;
			var centerY=(y0+y1+y2)/ 3;
			var normX=x0-centerX;
			var normY=y0-centerY;
			var dist=Math.sqrt((normX *normX)+(normY *normY));
			x0=centerX+((normX / dist)*(dist+paddingX));
			y0=centerY+((normY / dist)*(dist+paddingY));
			normX=x1-centerX;
			normY=y1-centerY;
			dist=Math.sqrt((normX *normX)+(normY *normY));
			x1=centerX+((normX / dist)*(dist+paddingX));
			y1=centerY+((normY / dist)*(dist+paddingY));
			normX=x2-centerX;
			normY=y2-centerY;
			dist=Math.sqrt((normX *normX)+(normY *normY));
			x2=centerX+((normX / dist)*(dist+paddingX));
			y2=centerY+((normY / dist)*(dist+paddingY));
		}
		this.save();
		if (matrix)
			this.transform(matrix.a,matrix.b,matrix.c,matrix.d,matrix.tx,matrix.ty);
		this.beginPath();
		this.moveTo(x0,y0);
		this.lineTo(x1,y1);
		this.lineTo(x2,y2);
		this.closePath();
		this.clip();
		var delta=(u0 *v1)+(v0 *u2)+(u1 *v2)-(v1 *u2)-(v0 *u1)-(u0 *v2);
		var dDelta=1 / delta;
		var deltaA=(x0 *v1)+(v0 *x2)+(x1 *v2)-(v1 *x2)-(v0 *x1)-(x0 *v2);
		var deltaB=(u0 *x1)+(x0 *u2)+(u1 *x2)-(x1 *u2)-(x0 *u1)-(u0 *x2);
		var deltaC=(u0 *v1 *x2)+(v0 *x1 *u2)+(x0 *u1 *v2)-(x0 *v1 *u2)-(v0 *u1 *x2)-(u0 *x1 *v2);
		var deltaD=(y0 *v1)+(v0 *y2)+(y1 *v2)-(v1 *y2)-(v0 *y1)-(y0 *v2);
		var deltaE=(u0 *y1)+(y0 *u2)+(u1 *y2)-(y1 *u2)-(y0 *u1)-(u0 *y2);
		var deltaF=(u0 *v1 *y2)+(v0 *y1 *u2)+(y0 *u1 *v2)-(y0 *v1 *u2)-(v0 *u1 *y2)-(u0 *y1 *v2);
		this.transform(deltaA *dDelta,deltaD *dDelta,deltaB *dDelta,deltaE *dDelta,deltaC *dDelta,deltaF *dDelta);
		this.drawImage(textureSource,texture.uv[0] *sourceWidth,texture.uv[1] *sourceHeight,textureWidth,textureHeight,texture.uv[0] *sourceWidth,texture.uv[1] *sourceHeight,textureWidth,textureHeight);
		this.restore();
	}

	//=============新增==================
	__proto.transformByMatrix=function(matrix,tx,ty){
		this.transform(matrix.a,matrix.b,matrix.c,matrix.d,matrix.tx+tx,matrix.ty+ty);
	}

	__proto.saveTransform=function(matrix){
		this.save();
	}

	__proto.restoreTransform=function(matrix){
		this.restore();
	}

	__proto.drawRect=function(x,y,width,height,fillColor,lineColor,lineWidth){
		var ctx=this;
		if (fillColor !=null){
			ctx.fillStyle=fillColor;
			ctx.fillRect(x,y,width,height);
		}
		if (lineColor !=null){
			ctx.strokeStyle=lineColor;
			ctx.lineWidth=lineWidth;
			ctx.strokeRect(x,y,width,height);
		}
	}

	//TODO:coverage
	__proto.drawTexture=function(tex,x,y,width,height){
		var source=tex._getSource();
		if (!source)return;
		Stat.drawCall++;
		var uv=tex.uv,w=tex.bitmap.width,h=tex.bitmap.height;
		this.drawImage(source,uv[0] *w,uv[1] *h,(uv[2]-uv[0])*w,(uv[5]-uv[3])*h,x,y,width,height);
	}

	__proto.drawTextures=function(tex,pos,tx,ty){
		Stat.drawCall+=pos.length / 2;
		var w=tex.width;
		var h=tex.height;
		for (var i=0,sz=pos.length;i < sz;i+=2){
			this.drawTexture(tex,pos[i]+tx,pos[i+1]+ty,w,h);
		}
	}

	//TODO:coverage
	__proto.drawTriangles=function(texture,x,y,vertices,uvs,indices,matrix,alpha,color,blendMode){
		var i=0,len=indices.length;
		this.translate(x,y);
		for (i=0;i < len;i+=3){
			var index0=indices[i] *2;
			var index1=indices[i+1] *2;
			var index2=indices[i+2] *2;
			this.drawTriangle(texture,vertices,uvs,index0,index1,index2,matrix,true);
		}
		this.translate(-x,-y);
	}

	__proto.alpha=function(value){
		this.globalAlpha *=value;
	}

	//TODO:coverage
	__proto._transform=function(mat,pivotX,pivotY){
		this.translate(pivotX,pivotY);
		this.transform(mat.a,mat.b,mat.c,mat.d,mat.tx,mat.ty);
		this.translate(-pivotX,-pivotY);
	}

	__proto._rotate=function(angle,pivotX,pivotY){
		this.translate(pivotX,pivotY);
		this.rotate(angle);
		this.translate(-pivotX,-pivotY);
	}

	__proto._scale=function(scaleX,scaleY,pivotX,pivotY){
		this.translate(pivotX,pivotY);
		this.scale(scaleX,scaleY);
		this.translate(-pivotX,-pivotY);
	}

	__proto._drawLine=function(x,y,fromX,fromY,toX,toY,lineColor,lineWidth,vid){
		this.beginPath();
		this.strokeStyle=lineColor;
		this.lineWidth=lineWidth;
		this.moveTo(x+fromX,y+fromY);
		this.lineTo(x+toX,y+toY);
		this.stroke();
	}

	__proto._drawLines=function(x,y,points,lineColor,lineWidth,vid){
		Render.isWebGL && this.setPathId(vid);
		this.beginPath();
		this.strokeStyle=lineColor;
		this.lineWidth=lineWidth;
		var i=2,n=points.length;
		if (Render.isWebGL){
			this.addPath(points.slice(),false,false,x,y);
			}else {
			this.moveTo(x+points[0],y+points[1]);
			while (i < n){
				this.lineTo(x+points[i++],y+points[i++]);
			}
		}
		this.stroke();
	}

	__proto.drawCurves=function(x,y,points,lineColor,lineWidth){
		this.beginPath();
		this.strokeStyle=lineColor;
		this.lineWidth=lineWidth;
		this.moveTo(x+points[0],y+points[1]);
		var i=2,n=points.length;
		while (i < n){
			this.quadraticCurveTo(x+points[i++],y+points[i++],x+points[i++],y+points[i++]);
		}
		this.stroke();
	}

	__proto._fillAndStroke=function(fillColor,strokeColor,lineWidth,isConvexPolygon){
		(isConvexPolygon===void 0)&& (isConvexPolygon=false);
		if (fillColor !=null){
			this.fillStyle=fillColor;
			this.fill();
		}
		if (strokeColor !=null && lineWidth > 0){
			this.strokeStyle=strokeColor;
			this.lineWidth=lineWidth;
			this.stroke();
		}
	}

	__proto._drawCircle=function(x,y,radius,fillColor,lineColor,lineWidth,vid){
		Stat.drawCall++;
		Render.isWebGL? this.beginPath(true):this.beginPath();
		this.arc(x,y,radius,0,Context.PI2);
		this.closePath();
		this._fillAndStroke(fillColor,lineColor,lineWidth);
	}

	//矢量方法
	__proto._drawPie=function(x,y,radius,startAngle,endAngle,fillColor,lineColor,lineWidth,vid){
		this.beginPath();
		this.moveTo(x ,y);
		this.arc(x,y,radius,startAngle,endAngle);
		this.closePath();
		this._fillAndStroke(fillColor,lineColor,lineWidth);
	}

	//ctx.translate(-x-args[0],-y-args[1]);
	__proto._drawPoly=function(x,y,points,fillColor,lineColor,lineWidth,isConvexPolygon,vid){
		var i=2,n=points.length;
		this.beginPath();
		if (Render.isWebGL){
			this.setPathId(vid);
			this.addPath(points.slice(),true,isConvexPolygon,x,y);
			}else {
			this.moveTo(x+points[0],y+points[1]);
			while (i < n){
				this.lineTo(x+points[i++],y+points[i++]);
			}
		}
		this.closePath();
		this._fillAndStroke(fillColor,lineColor,lineWidth,isConvexPolygon);
	}

	__proto._drawPath=function(x,y,paths,brush,pen){
		this.beginPath();
		for (var i=0,n=paths.length;i < n;i++){
			var path=paths[i];
			switch (path[0]){
				case "moveTo":
					this.moveTo(x+path[1],y+path[2]);
					break ;
				case "lineTo":
					this.lineTo(x+path[1],y+path[2]);
					break ;
				case "arcTo":
					this.arcTo(x+path[1],y+path[2],x+path[3],y+path[4],path[5]);
					break ;
				case "closePath":
					this.closePath();
					break ;
				}
		}
		if (brush !=null){
			this.fillStyle=brush.fillStyle;
			this.fill();
		}
		if (pen !=null){
			this.strokeStyle=pen.strokeStyle;
			this.lineWidth=pen.lineWidth || 1;
			this.lineJoin=pen.lineJoin;
			this.lineCap=pen.lineCap;
			this.miterLimit=pen.miterLimit;
			this.stroke();
		}
	}

	__proto.drawParticle=function(x,y,pt){}
	Context.__init__=function(to){
		var from=laya.resource.Context.prototype;
		to=to || CanvasRenderingContext2D.prototype;
		if(to.init2d)return;
		to.init2d=true;
		var funs=["saveTransform","restoreTransform","transformByMatrix","drawTriangles","drawTriangle",'drawTextures','fillWords','fillBorderWords','drawRect','strokeWord','drawText','fillTexture','setTransformByMatrix','clipRect','drawTexture','drawTexture2','drawTextureWithTransform','flush','clear','destroy','drawCanvas','fillBorderText','drawCurves',"_drawRect","alpha","_transform","_rotate","_scale","_drawLine","_drawLines","_drawCircle","_fillAndStroke","_drawPie","_drawPoly","_drawPath","drawTextureWithTransform"];
		funs.forEach(function(i){
			to[i]=from[i];
		});
	}

	Context.ENUM_TEXTALIGN_DEFAULT=0;
	Context.ENUM_TEXTALIGN_CENTER=1;
	Context.ENUM_TEXTALIGN_RIGHT=2;
	Context.PI2=2 *Math.PI;
	return Context;
})()


//class laya.resource.ResourceManager
var ResourceManager=(function(){
	function ResourceManager(name){
		/**唯一标识ID。*/
		this._id=0;
		/**名字。*/
		this._name=null;
		/**所管理资源。*/
		this._resources=null;
		/**所管理资源的累计内存,以字节为单位。*/
		this._memorySize=0;
		this._id=++ResourceManager._uniqueIDCounter;
		this._name=name ? name :"Content Manager";
		ResourceManager._isResourceManagersSorted=false;
		this._memorySize=0;
		ResourceManager._resourceManagers.push(this);
		this._resources=[];
	}

	__class(ResourceManager,'laya.resource.ResourceManager');
	var __proto=ResourceManager.prototype;
	Laya.imps(__proto,{"laya.resource.IDispose":true})
	/**
	*获取指定索引的资源 Resource 对象。
	*@param 索引。
	*@return 资源 Resource 对象。
	*/
	__proto.getResourceByIndex=function(index){
		return this._resources[index];
	}

	/**
	*获取此管理器所管理的资源个数。
	*@return 资源个数。
	*/
	__proto.getResourcesLength=function(){
		return this._resources.length;
	}

	/**
	*添加指定资源。
	*@param resource 需要添加的资源 Resource 对象。
	*@return 是否添加成功。
	*/
	__proto.addResource=function(resource){
		if (resource.resourceManager)
			resource.resourceManager.removeResource(resource);
		var index=this._resources.indexOf(resource);
		if (index===-1){
			resource._resourceManager=this;
			this._resources.push(resource);
			this.addSize(resource.gpuMemory);
			return true;
		}
		return false;
	}

	/**
	*移除指定资源。
	*@param resource 需要移除的资源 Resource 对象
	*@return 是否移除成功。
	*/
	__proto.removeResource=function(resource){
		var index=this._resources.indexOf(resource);
		if (index!==-1){
			this._resources.splice(index,1);
			resource._resourceManager=null;
			this._memorySize-=resource.gpuMemory;
			return true;
		}
		return false;
	}

	/**
	*卸载此资源管理器载入的资源。
	*/
	__proto.unload=function(){
		var tempResources=this._resources.slice(0,this._resources.length);
		for (var i=0;i < tempResources.length;i++){
			var resource=tempResources[i];
			resource.destroy();
		}
		tempResources.length=0;
	}

	/**释放资源。*/
	__proto.dispose=function(){
		if (this===ResourceManager._systemResourceManager)
			throw new Error("systemResourceManager不能被释放！");
		ResourceManager._resourceManagers.splice(ResourceManager._resourceManagers.indexOf(this),1);
		ResourceManager._isResourceManagersSorted=false;
		var tempResources=this._resources.slice(0,this._resources.length);
		for (var i=0;i < tempResources.length;i++){
			var resource=tempResources[i];
			resource.resourceManager.removeResource(resource);
			resource.destroy();
		}
		tempResources.length=0;
	}

	/**
	*增加内存。
	*@param add 需要增加的内存大小。
	*/
	__proto.addSize=function(add){
		if (add){
			this._memorySize+=add;
		}
	}

	/**
	*唯一标识 ID 。
	*/
	__getset(0,__proto,'id',function(){
		return this._id;
	});

	/**
	*名字。
	*/
	__getset(0,__proto,'name',function(){
		return this._name;
		},function(value){
		if ((value || value!=="")&& this._name!==value){
			this._name=value;
			ResourceManager._isResourceManagersSorted=false;
		}
	});

	/**
	*此管理器所管理资源的累计内存，以字节为单位。
	*/
	__getset(0,__proto,'memorySize',function(){
		return this._memorySize;
	});

	/**
	*系统资源管理器。
	*/
	__getset(1,ResourceManager,'systemResourceManager',function(){
		return ResourceManager._systemResourceManager;
	});

	ResourceManager.__init__=function(){
		ResourceManager.currentResourceManager=ResourceManager.systemResourceManager;
	}

	ResourceManager.getLoadedResourceManagerByIndex=function(index){
		return ResourceManager._resourceManagers[index];
	}

	ResourceManager.getLoadedResourceManagersCount=function(){
		return ResourceManager._resourceManagers.length;
	}

	ResourceManager.recreateContentManagers=function(force){
		(force===void 0)&& (force=false);
	}

	ResourceManager.releaseContentManagers=function(force){
		(force===void 0)&& (force=false);
		var temp=ResourceManager.currentResourceManager;
		for (var i=0;i < ResourceManager._resourceManagers.length;i++){
			ResourceManager.currentResourceManager=ResourceManager._resourceManagers[i];
			for (var j=0;j < ResourceManager.currentResourceManager._resources.length;j++){
				var resource=ResourceManager.currentResourceManager._resources[j];
				(!resource.released)&& (resource.releaseResource(force));
			}
		}
		ResourceManager.currentResourceManager=temp;
	}

	ResourceManager._uniqueIDCounter=0;
	ResourceManager._isResourceManagersSorted=false;
	ResourceManager._resourceManagers=[];
	__static(ResourceManager,
	['_systemResourceManager',function(){return this._systemResourceManager=new ResourceManager("System Resource Manager");},'currentResourceManager',function(){return this.currentResourceManager=ResourceManager._systemResourceManager;}
	]);
	return ResourceManager;
})()


//class laya.ui.Styles
var Styles=(function(){
	function Styles(){}
	__class(Styles,'laya.ui.Styles');
	Styles.labelColor="#000000";
	Styles.buttonStateNum=3;
	Styles.scrollBarMinNum=15;
	Styles.scrollBarDelayTime=500;
	__static(Styles,
	['defaultSizeGrid',function(){return this.defaultSizeGrid=[4,4,4,4,0];},'labelPadding',function(){return this.labelPadding=[2,2,2,2];},'inputLabelPadding',function(){return this.inputLabelPadding=[1,1,1,3];},'buttonLabelColors',function(){return this.buttonLabelColors=["#32556b","#32cc6b","#ff0000","#C0C0C0"];},'comboBoxItemColors',function(){return this.comboBoxItemColors=["#5e95b6","#ffffff","#000000","#8fa4b1","#ffffff"];}
	]);
	return Styles;
})()


//class laya.ui.UIUtils
var UIUtils=(function(){
	function UIUtils(){}
	__class(UIUtils,'laya.ui.UIUtils');
	UIUtils.fillArray=function(arr,str,type){
		var temp=arr.concat();
		if (str){
			var a=str.split(",");
			for (var i=0,n=Math.min(temp.length,a.length);i < n;i++){
				var value=a[i];
				temp[i]=(value=="true" ? true :(value=="false" ? false :value));
				if (type !=null)temp[i]=type(value);
			}
		}
		return temp;
	}

	UIUtils.toColor=function(color){
		return Utils.toHexColor(color);
	}

	UIUtils.gray=function(traget,isGray){
		(isGray===void 0)&& (isGray=true);
		if (isGray){
			UIUtils.addFilter(traget,UIUtils.grayFilter);
			}else {
			UIUtils.clearFilter(traget,ColorFilter);
		}
	}

	UIUtils.addFilter=function(target,filter){
		var filters=target.filters || [];
		filters.push(filter);
		target.filters=filters;
	}

	UIUtils.clearFilter=function(target,filterType){
		var filters=target.filters;
		if (filters !=null && filters.length > 0){
			for (var i=filters.length-1;i >-1;i--){
				var filter=filters[i];
				if (Laya.__typeof(filter,filterType))filters.splice(i,1);
			}
			target.filters=filters;
		}
	}

	UIUtils._getReplaceStr=function(word){
		return UIUtils.escapeSequence[word];
	}

	UIUtils.adptString=function(str){
		return str.replace(/\\(\w)/g,UIUtils._getReplaceStr);
	}

	UIUtils.getBindFun=function(value){
		var fun=UIUtils._funMap.get(value);
		if (fun==null){
			var temp="\""+value+"\"";
			temp=temp.replace(/^"\${|}"$/g,"").replace(/\${/g,"\"+").replace(/}/g,"+\"");
			var str="(function(data){if(data==null)return;with(data){try{\nreturn "+temp+"\n}catch(e){}}})";
			fun=Laya._runScript(str);
			UIUtils._funMap.set(value,fun);
		}
		return fun;
	}

	__static(UIUtils,
	['grayFilter',function(){return this.grayFilter=new ColorFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0]);},'escapeSequence',function(){return this.escapeSequence={"\\n":"\n","\\t":"\t"};},'_funMap',function(){return this._funMap=new WeakObject();}
	]);
	return UIUtils;
})()


//class laya.utils.Browser
var Browser=(function(){
	function Browser(){}
	__class(Browser,'laya.utils.Browser');
	/**获得设备像素比。*/
	__getset(1,Browser,'pixelRatio',function(){
		if (Browser._pixelRatio < 0){
			Browser.__init__();
			if (Browser.userAgent.indexOf("Mozilla/6.0(Linux; Android 6.0; HUAWEI NXT-AL10 Build/HUAWEINXT-AL10)")>-1)Browser._pixelRatio=2;
			else {
				var ctx=Browser.context;
				var backingStore=ctx.backingStorePixelRatio || ctx.webkitBackingStorePixelRatio || ctx.mozBackingStorePixelRatio || ctx.msBackingStorePixelRatio || ctx.oBackingStorePixelRatio || ctx.backingStorePixelRatio || 1;
				Browser._pixelRatio=(Browser._window.devicePixelRatio || 1)/ backingStore;
				if (Browser._pixelRatio < 1)Browser._pixelRatio=1;
			}
		}
		return Browser._pixelRatio;
	});

	/**浏览器窗口物理高度。考虑了设备像素比。*/
	__getset(1,Browser,'height',function(){
		Browser.__init__();
		return ((Laya.stage && Laya.stage.canvasRotation)? Browser.clientWidth :Browser.clientHeight)*Browser.pixelRatio;
	});

	/**
	*浏览器窗口可视宽度。
	*通过分析浏览器信息获得。浏览器多个属性值优先级为：window.innerWidth(包含滚动条宽度)> document.body.clientWidth(不包含滚动条宽度)，如果前者为0或为空，则选择后者。
	*/
	__getset(1,Browser,'clientWidth',function(){
		Browser.__init__();
		return Browser._window.innerWidth || Browser._document.body.clientWidth;
	});

	/**浏览器原生 window 对象的引用。*/
	__getset(1,Browser,'window',function(){
		return Browser._window || Browser.__init__();
	});

	/**
	*浏览器窗口可视高度。
	*通过分析浏览器信息获得。浏览器多个属性值优先级为：window.innerHeight(包含滚动条高度)> document.body.clientHeight(不包含滚动条高度)> document.documentElement.clientHeight(不包含滚动条高度)，如果前者为0或为空，则选择后者。
	*/
	__getset(1,Browser,'clientHeight',function(){
		Browser.__init__();
		return Browser._window.innerHeight || Browser._document.body.clientHeight || Browser._document.documentElement.clientHeight;
	});

	/**浏览器窗口物理宽度。考虑了设备像素比。*/
	__getset(1,Browser,'width',function(){
		Browser.__init__();
		return ((Laya.stage && Laya.stage.canvasRotation)? Browser.clientHeight :Browser.clientWidth)*Browser.pixelRatio;
	});

	/**画布容器，用来盛放画布的容器。方便对画布进行控制*/
	__getset(1,Browser,'container',function(){
		if (!Browser._container){
			Browser.__init__();
			Browser._container=Browser.createElement("div");
			Browser._container.id="layaContainer";
			Browser._document.body.appendChild(Browser._container);
		}
		return Browser._container;
		},function(value){
		Browser._container=value;
	});

	/**浏览器原生 document 对象的引用。*/
	__getset(1,Browser,'document',function(){
		Browser.__init__();
		return Browser._document;
	});

	Browser.__init__=function(){
		if (Browser._window)return Browser._window;
		var win=Browser._window=window;
		var doc=Browser._document=win.document;
		var u=Browser.userAgent=win.navigator.userAgent;
		var libs=win._layalibs;
		if (libs){
			libs.sort(function(a,b){
				return a.i > b.i;
			});
			for (var j=0;j < libs.length;j++){
				libs[j].f(win,doc,Laya);
			}
		}
		if (u.indexOf("MiniGame")>-1){
			if (!Laya["MiniAdpter"]){
				console.error("请先添加小游戏适配库,详细教程：https://ldc.layabox.com/doc/?nav=zh-ts-5-0-0");
				}else {
				Laya["MiniAdpter"].enable();
			}
		}
		win.trace=console.log;
		win.requestAnimationFrame=win.requestAnimationFrame || win.webkitRequestAnimationFrame || win.mozRequestAnimationFrame || win.oRequestAnimationFrame || win.msRequestAnimationFrame || function (fun){
			return win.setTimeout(fun,1000 / 60);
		};
		var bodyStyle=doc.body.style;
		bodyStyle.margin=0;
		bodyStyle.overflow='hidden';
		bodyStyle['-webkit-user-select']='none';
		bodyStyle['-webkit-tap-highlight-color']='rgba(200,200,200,0)';
		var metas=doc.getElementsByTagName('meta');
		var i=0,flag=false,content='width=device-width,initial-scale=1.0,minimum-scale=1.0,maximum-scale=1.0,user-scalable=no';
		while (i < metas.length){
			var meta=metas[i];
			if (meta.name=='viewport'){
				meta.content=content;
				flag=true;
				break ;
			}
			i++;
		}
		if (!flag){
			meta=doc.createElement('meta');
			meta.name='viewport',meta.content=content;
			doc.getElementsByTagName('head')[0].appendChild(meta);
		}
		Browser.onMobile=u.indexOf("Mobile")>-1;
		Browser.onIOS=!!u.match(/\(i[^;]+;(U;)? CPU.+Mac OS X/);
		Browser.onIPhone=u.indexOf("iPhone")>-1;
		Browser.onMac=/*[SAFE]*/ u.indexOf("Mac OS X")>-1;
		Browser.onIPad=u.indexOf("iPad")>-1;
		Browser.onAndroid=u.indexOf('Android')>-1 || u.indexOf('Adr')>-1;
		Browser.onWP=u.indexOf("Windows Phone")>-1;
		Browser.onQQBrowser=u.indexOf("QQBrowser")>-1;
		Browser.onMQQBrowser=u.indexOf("MQQBrowser")>-1 || (u.indexOf("Mobile")>-1 && u.indexOf("QQ")>-1);
		Browser.onIE=!!win.ActiveXObject || "ActiveXObject" in win;
		Browser.onWeiXin=u.indexOf('MicroMessenger')>-1;
		Browser.onSafari=/*[SAFE]*/ u.indexOf("Safari")>-1;
		Browser.onPC=!Browser.onMobile;
		Browser.onMiniGame=/*[SAFE]*/ u.indexOf('MiniGame')>-1;
		Browser.onLimixiu=/*[SAFE]*/ u.indexOf('limixiu')>-1;
		Browser.supportLocalStorage=LocalStorage.__init__();
		Browser.supportWebAudio=SoundManager.__init__();
		Render._mainCanvas=new HTMLCanvas(true);
		var style=Render._mainCanvas.source.style;
		style.position='absolute';
		style.top=style.left="0px";
		style.background="#000000";
		Browser.canvas=new HTMLCanvas(true);
		Browser.context=Browser.canvas.getContext('2d');
		var tmpCanv=new HTMLCanvas(true);
		var names=["webgl","experimental-webgl","webkit-3d","moz-webgl"];
		var gl=null;
		for (i=0;i < names.length;i++){
			try {
				gl=tmpCanv.source.getContext(names[i]);
			}catch (e){}
			if (gl){
				Browser._supportWebGL=true;
				break ;
			}
		}
		return win;
	}

	Browser.createElement=function(type){
		Browser.__init__();
		return Browser._document.createElement(type);
	}

	Browser.getElementById=function(type){
		Browser.__init__();
		return Browser._document.getElementById(type);
	}

	Browser.removeElement=function(ele){
		if (ele && ele.parentNode)ele.parentNode.removeChild(ele);
	}

	Browser.now=function(){
		return Date.now();;
	}

	Browser.userAgent=null;
	Browser.onMobile=false;
	Browser.onIOS=false;
	Browser.onMac=false;
	Browser.onIPhone=false;
	Browser.onIPad=false;
	Browser.onAndroid=false;
	Browser.onWP=false;
	Browser.onQQBrowser=false;
	Browser.onMQQBrowser=false;
	Browser.onSafari=false;
	Browser.onIE=false;
	Browser.onWeiXin=false;
	Browser.onPC=false;
	Browser.onMiniGame=false;
	Browser.onLimixiu=false;
	Browser.onFirefox=false;
	Browser.onEdge=false;
	Browser.supportWebAudio=false;
	Browser.supportLocalStorage=false;
	Browser.canvas=null;
	Browser.context=null;
	Browser._window=null;
	Browser._document=null;
	Browser._container=null;
	Browser._pixelRatio=-1;
	Browser._supportWebGL=false;
	return Browser;
})()


//class laya.utils.CacheManger
var CacheManger=(function(){
	function CacheManger(){}
	__class(CacheManger,'laya.utils.CacheManger');
	CacheManger.regCacheByFunction=function(disposeFunction,getCacheListFunction){
		CacheManger.unRegCacheByFunction(disposeFunction,getCacheListFunction);
		var cache;
		cache={tryDispose:disposeFunction,getCacheList:getCacheListFunction};
		CacheManger._cacheList.push(cache);
	}

	CacheManger.unRegCacheByFunction=function(disposeFunction,getCacheListFunction){
		var i=0,len=0;
		len=CacheManger._cacheList.length;
		for (i=0;i < len;i++){
			if (CacheManger._cacheList[i].tryDispose==disposeFunction && CacheManger._cacheList[i].getCacheList==getCacheListFunction){
				CacheManger._cacheList.splice(i,1);
				return;
			}
		}
	}

	CacheManger.forceDispose=function(){
		var i=0,len=CacheManger._cacheList.length;
		for (i=0;i < len;i++){
			CacheManger._cacheList[i].tryDispose(true);
		}
	}

	CacheManger.beginCheck=function(waitTime){
		(waitTime===void 0)&& (waitTime=15000);
		Laya.systemTimer.loop(waitTime,null,CacheManger._checkLoop);
	}

	CacheManger.stopCheck=function(){
		Laya.systemTimer.clear(null,CacheManger._checkLoop);
	}

	CacheManger._checkLoop=function(){
		var cacheList=CacheManger._cacheList;
		if (cacheList.length < 1)return;
		var tTime=Browser.now();
		var count=0;
		var len=0;
		len=count=cacheList.length;
		while (count > 0){
			CacheManger._index++;
			CacheManger._index=CacheManger._index % len;
			cacheList[CacheManger._index].tryDispose(false);
			if (Browser.now()-tTime > CacheManger.loopTimeLimit)break ;
			count--;
		}
	}

	CacheManger.loopTimeLimit=2;
	CacheManger._cacheList=[];
	CacheManger._index=0;
	return CacheManger;
})()


//class laya.utils.CallLater
var CallLater=(function(){
	var LaterHandler;
	function CallLater(){
		/**@private */
		this._pool=[];
		/**@private */
		this._map=[];
		/**@private */
		this._laters=[];
	}

	__class(CallLater,'laya.utils.CallLater');
	var __proto=CallLater.prototype;
	/**
	*@private
	*帧循环处理函数。
	*/
	__proto._update=function(){
		var laters=this._laters;
		var len=laters.length;
		if (len > 0){
			for (var i=0,n=len-1;i <=n;i++){
				var handler=laters[i];
				this._map[handler.key]=null;
				if (handler.method!==null){
					handler.run();
					handler.clear();
				}
				this._pool.push(handler);
				i===n && (n=laters.length-1);
			}
			laters.length=0;
		}
	}

	/**@private */
	__proto._getHandler=function(caller,method){
		var cid=caller ? caller.$_GID || (caller.$_GID=Utils.getGID()):0;
		var mid=method.$_TID || (method.$_TID=(Timer._mid++)*100000);
		return this._map[cid+mid];
	}

	/**
	*延迟执行。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*@param args 回调参数。
	*/
	__proto.callLater=function(caller,method,args){
		if (this._getHandler(caller,method)==null){
			if (this._pool.length)
				var handler=this._pool.pop();
			else handler=new LaterHandler();
			handler.caller=caller;
			handler.method=method;
			handler.args=args;
			var cid=caller ? caller.$_GID :0;
			var mid=method["$_TID"];
			handler.key=cid+mid;
			this._map[handler.key]=handler
			this._laters.push(handler);
		}
	}

	/**
	*立即执行 callLater 。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*/
	__proto.runCallLater=function(caller,method){
		var handler=this._getHandler(caller,method);
		if (handler && handler.method !=null){
			this._map[handler.key]=null;
			handler.run();
			handler.clear();
		}
	}

	CallLater.I=new CallLater();
	CallLater.__init$=function(){
		/**@private */
		//class LaterHandler
		LaterHandler=(function(){
			function LaterHandler(){
				this.key=0;
				this.caller=null;
				this.method=null;
				this.args=null;
			}
			__class(LaterHandler,'');
			var __proto=LaterHandler.prototype;
			__proto.clear=function(){
				this.caller=null;
				this.method=null;
				this.args=null;
			}
			__proto.run=function(){
				var caller=this.caller;
				if (caller && caller.destroyed)return this.clear();
				var method=this.method;
				var args=this.args;
				if (method==null)return;
				args ? method.apply(caller,args):method.call(caller);
			}
			return LaterHandler;
		})()
	}

	return CallLater;
})()


//class laya.utils.ClassUtils
var ClassUtils=(function(){
	function ClassUtils(){}
	__class(ClassUtils,'laya.utils.ClassUtils');
	ClassUtils.regClass=function(className,classDef){
		ClassUtils._classMap[className]=classDef;
	}

	ClassUtils.regShortClassName=function(classes){
		for (var i=0;i < classes.length;i++){
			var classDef=classes[i];
			var className=classDef.name;
			ClassUtils._classMap[className]=classDef;
		}
	}

	ClassUtils.getRegClass=function(className){
		return ClassUtils._classMap[className];
	}

	ClassUtils.getClass=function(className){
		var classObject=ClassUtils._classMap[className] || className;
		if ((typeof classObject=='string'))return (Laya["__classmap"][classObject] || Laya[className]);
		return classObject;
	}

	ClassUtils.getInstance=function(className){
		var compClass=ClassUtils.getClass(className);
		if (compClass)return new compClass();
		else console.warn("[error] Undefined class:",className);
		return null;
	}

	ClassUtils.createByJson=function(json,node,root,customHandler,instanceHandler){
		if ((typeof json=='string'))json=JSON.parse(json);
		var props=json.props;
		if (!node){
			node=instanceHandler ? instanceHandler.runWith(json):ClassUtils.getInstance(props.runtime || json.type);
			if (!node)return null;
		};
		var child=json.child;
		if (child){
			for (var i=0,n=child.length;i < n;i++){
				var data=child[i];
				if ((data.props.name==="render" || data.props.renderType==="render")&& node["_$set_itemRender"])
					node.itemRender=data;
				else {
					if (data.type=="Graphic"){
						ClassUtils._addGraphicsToSprite(data,node);
						}else if (ClassUtils._isDrawType(data.type)){
						ClassUtils._addGraphicToSprite(data,node,true);
						}else {
						var tChild=ClassUtils.createByJson(data,null,root,customHandler,instanceHandler)
						if (data.type==="Script"){
							if (tChild.hasOwnProperty("owner")){
								tChild["owner"]=node;
								}else if (tChild.hasOwnProperty("target")){
								tChild["target"]=node;
							}
							}else if (data.props.renderType=="mask"){
							node.mask=tChild;
							}else {
							node.addChild(tChild);
						}
					}
				}
			}
		}
		if (props){
			for (var prop in props){
				var value=props[prop];
				if (prop==="var" && root){
					root[value]=node;
					}else if ((value instanceof Array)&& (typeof (node[prop])=='function')){
					node[prop].apply(node,value);
					}else {
					node[prop]=value;
				}
			}
		}
		if (customHandler && json.customProps){
			customHandler.runWith([node,json]);
		}
		if (node["created"])node.created();
		return node;
	}

	ClassUtils._addGraphicsToSprite=function(graphicO,sprite){
		var graphics=graphicO.child;
		if (!graphics || graphics.length < 1)return;
		var g=ClassUtils._getGraphicsFromSprite(graphicO,sprite);
		var ox=0;
		var oy=0;
		if (graphicO.props){
			ox=ClassUtils._getObjVar(graphicO.props,"x",0);
			oy=ClassUtils._getObjVar(graphicO.props,"y",0);
		}
		if (ox !=0 && oy !=0){
			g.translate(ox,oy);
		};
		var i=0,len=0;
		len=graphics.length;
		for (i=0;i < len;i++){
			ClassUtils._addGraphicToGraphics(graphics[i],g);
		}
		if (ox !=0 && oy !=0){
			g.translate(-ox,-oy);
		}
	}

	ClassUtils._addGraphicToSprite=function(graphicO,sprite,isChild){
		(isChild===void 0)&& (isChild=false);
		var g=isChild ? ClassUtils._getGraphicsFromSprite(graphicO,sprite):sprite.graphics;
		ClassUtils._addGraphicToGraphics(graphicO,g);
	}

	ClassUtils._getGraphicsFromSprite=function(dataO,sprite){
		if (!dataO || !dataO.props)return sprite.graphics;
		var propsName=dataO.props.renderType;
		if (propsName==="hit" || propsName==="unHit"){
			var hitArea=sprite._style.hitArea || (sprite.hitArea=new HitArea());
			if (!hitArea[propsName]){
				hitArea[propsName]=new Graphics();
			};
			var g=hitArea[propsName];
		}
		if (!g)g=sprite.graphics;
		return g;
	}

	ClassUtils._getTransformData=function(propsO){
		var m;
		if (propsO.hasOwnProperty("pivotX")|| propsO.hasOwnProperty("pivotY")){
			m=m || new Matrix();
			m.translate(-ClassUtils._getObjVar(propsO,"pivotX",0),-ClassUtils._getObjVar(propsO,"pivotY",0));
		};
		var sx=ClassUtils._getObjVar(propsO,"scaleX",1),sy=ClassUtils._getObjVar(propsO,"scaleY",1);
		var rotate=ClassUtils._getObjVar(propsO,"rotation",0);
		var skewX=ClassUtils._getObjVar(propsO,"skewX",0);
		var skewY=ClassUtils._getObjVar(propsO,"skewY",0);
		if (sx !=1 || sy !=1 || rotate !=0){
			m=m || new Matrix();
			m.scale(sx,sy);
			m.rotate(rotate *0.0174532922222222);
		}
		return m;
	}

	ClassUtils._addGraphicToGraphics=function(graphicO,graphic){
		var propsO;
		propsO=graphicO.props;
		if (!propsO)return;
		var drawConfig;
		drawConfig=ClassUtils.DrawTypeDic[graphicO.type];
		if (!drawConfig)return;
		var g=graphic;
		var params=ClassUtils._getParams(propsO,drawConfig[1],drawConfig[2],drawConfig[3]);
		var m=ClassUtils._tM;
		if (m || ClassUtils._alpha !=1){
			g.save();
			if (m)g.transform(m);
			if (ClassUtils._alpha !=1)g.alpha(ClassUtils._alpha);
		}
		g[drawConfig[0]].apply(g,params);
		if (m || ClassUtils._alpha !=1){
			g.restore();
		}
	}

	ClassUtils._adptLineData=function(params){
		params[2]=parseFloat(params[0])+parseFloat(params[2]);
		params[3]=parseFloat(params[1])+parseFloat(params[3]);
		return params;
	}

	ClassUtils._adptTextureData=function(params){
		params[0]=Loader.getRes(params[0]);
		return params;
	}

	ClassUtils._adptLinesData=function(params){
		params[2]=ClassUtils._getPointListByStr(params[2]);
		return params;
	}

	ClassUtils._isDrawType=function(type){
		if (type==="Image")return false;
		return ClassUtils.DrawTypeDic.hasOwnProperty(type);
	}

	ClassUtils._getParams=function(obj,params,xPos,adptFun){
		(xPos===void 0)&& (xPos=0);
		var rst=ClassUtils._temParam;
		rst.length=params.length;
		var i=0,len=0;
		len=params.length;
		for (i=0;i < len;i++){
			rst[i]=ClassUtils._getObjVar(obj,params[i][0],params[i][1]);
		}
		ClassUtils._alpha=ClassUtils._getObjVar(obj,"alpha",1);
		var m;
		m=ClassUtils._getTransformData(obj);
		if (m){
			if (!xPos)xPos=0;
			m.translate(rst[xPos],rst[xPos+1]);
			rst[xPos]=rst[xPos+1]=0;
			ClassUtils._tM=m;
			}else {
			ClassUtils._tM=null;
		}
		if (adptFun && ClassUtils[adptFun]){
			rst=ClassUtils[adptFun](rst);
		}
		return rst;
	}

	ClassUtils._getPointListByStr=function(str){
		var pointArr=str.split(",");
		var i=0,len=0;
		len=pointArr.length;
		for (i=0;i < len;i++){
			pointArr[i]=parseFloat(pointArr[i]);
		}
		return pointArr;
	}

	ClassUtils._getObjVar=function(obj,key,noValue){
		if (obj.hasOwnProperty(key)){
			return obj[key];
		}
		return noValue;
	}

	ClassUtils._temParam=[];
	ClassUtils._classMap={'Sprite':Sprite,'Scene':Scene,'Text':Text,'Animation':'laya.display.Animation','Skeleton':'laya.ani.bone.Skeleton','Particle2D':'laya.particle.Particle2D','div':'laya.html.dom.HTMLDivParser','p':'laya.html.dom.HTMLElement','img':'laya.html.dom.HTMLImageElement','span':'laya.html.dom.HTMLElement','br':'laya.html.dom.HTMLBrElement','style':'laya.html.dom.HTMLStyleElement','font':'laya.html.dom.HTMLElement','a':'laya.html.dom.HTMLElement','#text':'laya.html.dom.HTMLElement','link':'laya.html.dom.HTMLLinkElement'};
	ClassUtils._tM=null;
	ClassUtils._alpha=NaN;
	__static(ClassUtils,
	['DrawTypeDic',function(){return this.DrawTypeDic={"Rect":["drawRect",[["x",0],["y",0],["width",0],["height",0],["fillColor",null],["lineColor",null],["lineWidth",1]]],"Circle":["drawCircle",[["x",0],["y",0],["radius",0],["fillColor",null],["lineColor",null],["lineWidth",1]]],"Pie":["drawPie",[["x",0],["y",0],["radius",0],["startAngle",0],["endAngle",0],["fillColor",null],["lineColor",null],["lineWidth",1]]],"Image":["drawTexture",[["x",0],["y",0],["width",0],["height",0]]],"Texture":["drawTexture",[["skin",null],["x",0],["y",0],["width",0],["height",0]],1,"_adptTextureData"],"FillTexture":["fillTexture",[["skin",null],["x",0],["y",0],["width",0],["height",0],["repeat",null]],1,"_adptTextureData"],"FillText":["fillText",[["text",""],["x",0],["y",0],["font",null],["color",null],["textAlign",null]],1],"Line":["drawLine",[["x",0],["y",0],["toX",0],["toY",0],["lineColor",null],["lineWidth",0]],0,"_adptLineData"],"Lines":["drawLines",[["x",0],["y",0],["points",""],["lineColor",null],["lineWidth",0]],0,"_adptLinesData"],"Curves":["drawCurves",[["x",0],["y",0],["points",""],["lineColor",null],["lineWidth",0]],0,"_adptLinesData"],"Poly":["drawPoly",[["x",0],["y",0],["points",""],["fillColor",null],["lineColor",null],["lineWidth",1]],0,"_adptLinesData"]};}
	]);
	return ClassUtils;
})()


//class laya.utils.ColorUtils
var ColorUtils=(function(){
	function ColorUtils(value){
		//TODO:delete？
		this.arrColor=[];
		/**字符串型颜色值。*/
		//this.strColor=null;
		/**uint 型颜色值。*/
		//this.numColor=0;
		/**@private TODO:*/
		//this._drawStyle=null;
		if (value==null){
			this.strColor="#00000000";
			this.numColor=0;
			this.arrColor=[0,0,0,0];
			return;
		};
		var i=0,len=0;
		var color=0;
		if ((typeof value=='string')){
			if ((value).indexOf("rgba(")>=0||(value).indexOf("rgb(")>=0){
				var tStr=value;
				var beginI=0,endI=0;
				beginI=tStr.indexOf("(");
				endI=tStr.indexOf(")");
				tStr=tStr.substring(beginI+1,endI);
				this.arrColor=tStr.split(",");
				len=this.arrColor.length;
				for (i=0;i < len;i++){
					this.arrColor[i]=parseFloat(this.arrColor[i]);
					if (i < 3){
						this.arrColor[i]=Math.round(this.arrColor[i]);
					}
				}
				if (this.arrColor.length==4){
					color=((this.arrColor[0] *256+this.arrColor[1])*256+this.arrColor[2])*256+Math.round(this.arrColor[3] *255);
					}else{
					color=((this.arrColor[0] *256+this.arrColor[1])*256+this.arrColor[2]);
				}
				this.strColor=value;
				}else{
				this.strColor=value;
				value.charAt(0)==='#' && (value=value.substr(1));
				len=value.length;
				if (len===3 || len===4){
					var temp="";
					for (i=0;i < len;i++){
						temp+=(value[i]+value[i]);
					}
					value=temp;
				}
				color=parseInt(value,16);
			}
			}else {
			color=value;
			this.strColor=Utils.toHexColor(color);
		}
		if (this.strColor.indexOf("rgba")>=0 || this.strColor.length===9){
			this.arrColor=[((0xFF000000 & color)>>>24)/ 255,((0xFF0000 & color)>> 16)/ 255,((0xFF00 & color)>>8)/ 255,(0xFF & color)/ 255];
			this.numColor=(0xff000000&color)>>>24|(color & 0xff0000)>> 8 | (color & 0x00ff00)<<8 | ((color & 0xff)<<24);
			}else {
			this.arrColor=[((0xFF0000 & color)>> 16)/ 255,((0xFF00 & color)>> 8)/ 255,(0xFF & color)/ 255,1];
			this.numColor=0xff000000|(color & 0xff0000)>> 16 | (color & 0x00ff00)| (color & 0xff)<< 16;
		}
		(this.arrColor).__id=++ColorUtils._COLODID;
	}

	__class(ColorUtils,'laya.utils.ColorUtils');
	ColorUtils._initDefault=function(){
		ColorUtils._DEFAULT={};
		for (var i in ColorUtils._COLOR_MAP)ColorUtils._SAVE[i]=ColorUtils._DEFAULT[i]=new ColorUtils(ColorUtils._COLOR_MAP[i]);
		return ColorUtils._DEFAULT;
	}

	ColorUtils._initSaveMap=function(){
		ColorUtils._SAVE_SIZE=0;
		ColorUtils._SAVE={};
		for (var i in ColorUtils._DEFAULT)ColorUtils._SAVE[i]=ColorUtils._DEFAULT[i];
	}

	ColorUtils.create=function(value){
		var key=value+"";
		var color=ColorUtils._SAVE[key];
		if (color !=null)return color;
		if (ColorUtils._SAVE_SIZE < 1000)ColorUtils._initSaveMap();
		return ColorUtils._SAVE[key]=new ColorUtils(value);
	}

	ColorUtils._SAVE={};
	ColorUtils._SAVE_SIZE=0;
	ColorUtils._COLOR_MAP={"purple":"#800080","orange":"#ffa500","white":'#FFFFFF',"red":'#FF0000',"green":'#00FF00',"blue":'#0000FF',"black":'#000000',"yellow":'#FFFF00','gray':'#808080' };
	ColorUtils._DEFAULT=ColorUtils._initDefault();
	ColorUtils._COLODID=1;
	return ColorUtils;
})()


//class laya.utils.Dragging
var Dragging=(function(){
	function Dragging(){
		/**被拖动的对象。*/
		//this.target=null;
		/**缓动衰减系数。*/
		this.ratio=0.92;
		/**单帧最大偏移量。*/
		this.maxOffset=60;
		/**滑动范围。*/
		//this.area=null;
		/**表示拖动是否有惯性。*/
		//this.hasInertia=false;
		/**橡皮筋最大值。*/
		//this.elasticDistance=NaN;
		/**橡皮筋回弹时间，单位为毫秒。*/
		//this.elasticBackTime=NaN;
		/**事件携带数据。*/
		//this.data=null;
		this._dragging=false;
		this._clickOnly=true;
		//this._elasticRateX=NaN;
		//this._elasticRateY=NaN;
		//this._lastX=NaN;
		//this._lastY=NaN;
		//this._offsetX=NaN;
		//this._offsetY=NaN;
		//this._offsets=null;
		//this._disableMouseEvent=false;
		//this._tween=null;
		//this._parent=null;
	}

	__class(Dragging,'laya.utils.Dragging');
	var __proto=Dragging.prototype;
	/**
	*开始拖拽。
	*@param target 待拖拽的 <code>Sprite</code> 对象。
	*@param area 滑动范围。
	*@param hasInertia 拖动是否有惯性。
	*@param elasticDistance 橡皮筋最大值。
	*@param elasticBackTime 橡皮筋回弹时间，单位为毫秒。
	*@param data 事件携带数据。
	*@param disableMouseEvent 鼠标事件是否有效。
	*@param ratio 惯性阻尼系数
	*/
	__proto.start=function(target,area,hasInertia,elasticDistance,elasticBackTime,data,disableMouseEvent,ratio){
		(ratio===void 0)&& (ratio=0.92);
		this.clearTimer();
		this.target=target;
		this.area=area;
		this.hasInertia=hasInertia;
		this.elasticDistance=area ? elasticDistance :0;
		this.elasticBackTime=elasticBackTime;
		this.data=data;
		this._disableMouseEvent=disableMouseEvent;
		this.ratio=ratio;
		this._parent=target.parent;
		this._clickOnly=true;
		this._dragging=true;
		this._elasticRateX=this._elasticRateY=1;
		this._lastX=this._parent.mouseX;
		this._lastY=this._parent.mouseY;
		Laya.stage.on("mouseup",this,this.onStageMouseUp);
		Laya.stage.on("mouseout",this,this.onStageMouseUp);
		Laya.systemTimer.frameLoop(1,this,this.loop);
	}

	/**
	*清除计时器。
	*/
	__proto.clearTimer=function(){
		Laya.systemTimer.clear(this,this.loop);
		Laya.systemTimer.clear(this,this.tweenMove);
		if (this._tween){
			this._tween.recover();
			this._tween=null;
		}
	}

	/**
	*停止拖拽。
	*/
	__proto.stop=function(){
		if (this._dragging){
			MouseManager.instance.disableMouseEvent=false;
			Laya.stage.off("mouseup",this,this.onStageMouseUp);
			Laya.stage.off("mouseout",this,this.onStageMouseUp);
			this._dragging=false;
			this.target && this.area && this.backToArea();
			this.clear();
		}
	}

	/**
	*拖拽的循环处理函数。
	*/
	__proto.loop=function(){
		var point=this._parent.getMousePoint();
		var mouseX=point.x;
		var mouseY=point.y;
		var offsetX=mouseX-this._lastX;
		var offsetY=mouseY-this._lastY;
		if (this._clickOnly){
			if (Math.abs(offsetX *Laya.stage._canvasTransform.getScaleX())> 1 || Math.abs(offsetY *Laya.stage._canvasTransform.getScaleY())> 1){
				this._clickOnly=false;
				this._offsets || (this._offsets=[]);
				this._offsets.length=0;
				this.target.event("dragstart",this.data);
				MouseManager.instance.disableMouseEvent=this._disableMouseEvent;
			}else return;
			}else {
			this._offsets.push(offsetX,offsetY);
		}
		if (offsetX===0 && offsetY===0)return;
		this._lastX=mouseX;
		this._lastY=mouseY;
		this.target.x+=offsetX *this._elasticRateX;
		this.target.y+=offsetY *this._elasticRateY;
		this.area && this.checkArea();
		this.target.event("dragmove",this.data);
	}

	/**
	*拖拽区域检测。
	*/
	__proto.checkArea=function(){
		if (this.elasticDistance <=0){
			this.backToArea();
			}else {
			if (this.target._x < this.area.x){
				var offsetX=this.area.x-this.target._x;
				}else if (this.target._x > this.area.x+this.area.width){
				offsetX=this.target._x-this.area.x-this.area.width;
				}else {
				offsetX=0;
			}
			this._elasticRateX=Math.max(0,1-(offsetX / this.elasticDistance));
			if (this.target._y < this.area.y){
				var offsetY=this.area.y-this.target.y;
				}else if (this.target._y > this.area.y+this.area.height){
				offsetY=this.target._y-this.area.y-this.area.height;
				}else {
				offsetY=0;
			}
			this._elasticRateY=Math.max(0,1-(offsetY / this.elasticDistance));
		}
	}

	/**
	*移动至设定的拖拽区域。
	*/
	__proto.backToArea=function(){
		this.target.x=Math.min(Math.max(this.target._x,this.area.x),this.area.x+this.area.width);
		this.target.y=Math.min(Math.max(this.target._y,this.area.y),this.area.y+this.area.height);
	}

	/**
	*舞台的抬起事件侦听函数。
	*@param e Event 对象。
	*/
	__proto.onStageMouseUp=function(e){
		MouseManager.instance.disableMouseEvent=false;
		Laya.stage.off("mouseup",this,this.onStageMouseUp);
		Laya.stage.off("mouseout",this,this.onStageMouseUp);
		Laya.systemTimer.clear(this,this.loop);
		if (this._clickOnly || !this.target)return;
		if (this.hasInertia){
			if (this._offsets.length < 1){
				this._offsets.push(this._parent.mouseX-this._lastX,this._parent.mouseY-this._lastY);
			}
			this._offsetX=this._offsetY=0;
			var len=this._offsets.length;
			var n=Math.min(len,6);
			var m=this._offsets.length-n;
			for (var i=len-1;i > m;i--){
				this._offsetY+=this._offsets[i--];
				this._offsetX+=this._offsets[i];
			}
			this._offsetX=this._offsetX / n *2;
			this._offsetY=this._offsetY / n *2;
			if (Math.abs(this._offsetX)> this.maxOffset)this._offsetX=this._offsetX > 0 ? this.maxOffset :-this.maxOffset;
			if (Math.abs(this._offsetY)> this.maxOffset)this._offsetY=this._offsetY > 0 ? this.maxOffset :-this.maxOffset;
			Laya.systemTimer.frameLoop(1,this,this.tweenMove);
			}else if (this.elasticDistance > 0){
			this.checkElastic();
			}else {
			this.clear();
		}
	}

	/**
	*橡皮筋效果检测。
	*/
	__proto.checkElastic=function(){
		var tx=NaN;
		var ty=NaN;
		if (this.target.x < this.area.x)tx=this.area.x;
		else if (this.target._x > this.area.x+this.area.width)tx=this.area.x+this.area.width;
		if (this.target.y < this.area.y)ty=this.area.y;
		else if (this.target._y > this.area.y+this.area.height)ty=this.area.y+this.area.height;
		if (!isNaN(tx)|| !isNaN(ty)){
			var obj={};
			if (!isNaN(tx))obj.x=tx;
			if (!isNaN(ty))obj.y=ty;
			this._tween=Tween.to(this.target,obj,this.elasticBackTime,Ease.sineOut,Handler.create(this,this.clear),0,false,false);
			}else {
			this.clear();
		}
	}

	/**
	*移动。
	*/
	__proto.tweenMove=function(){
		this._offsetX *=this.ratio *this._elasticRateX;
		this._offsetY *=this.ratio *this._elasticRateY;
		this.target.x+=this._offsetX;
		this.target.y+=this._offsetY;
		this.area && this.checkArea();
		this.target.event("dragmove",this.data);
		if ((Math.abs(this._offsetX)< 1 && Math.abs(this._offsetY)< 1)|| this._elasticRateX < 0.5 || this._elasticRateY < 0.5){
			Laya.systemTimer.clear(this,this.tweenMove);
			if (this.elasticDistance > 0)this.checkElastic();
			else this.clear();
		}
	}

	/**
	*结束拖拽。
	*/
	__proto.clear=function(){
		if (this.target){
			this.clearTimer();
			var sp=this.target;
			this.target=null;
			this._parent=null;
			sp.event("dragend",this.data);
		}
	}

	return Dragging;
})()


//class laya.utils.Ease
var Ease=(function(){
	function Ease(){}
	__class(Ease,'laya.utils.Ease');
	Ease.linearNone=function(t,b,c,d){
		return c *t / d+b;
	}

	Ease.linearIn=function(t,b,c,d){
		return c *t / d+b;
	}

	Ease.linearInOut=function(t,b,c,d){
		return c *t / d+b;
	}

	Ease.linearOut=function(t,b,c,d){
		return c *t / d+b;
	}

	Ease.bounceIn=function(t,b,c,d){
		return c-Ease.bounceOut(d-t,0,c,d)+b;
	}

	Ease.bounceInOut=function(t,b,c,d){
		if (t < d *0.5)return Ease.bounceIn(t *2,0,c,d)*.5+b;
		else return Ease.bounceOut(t *2-d,0,c,d)*.5+c *.5+b;
	}

	Ease.bounceOut=function(t,b,c,d){
		if ((t /=d)< (1 / 2.75))return c *(7.5625 *t *t)+b;
		else if (t < (2 / 2.75))return c *(7.5625 *(t-=(1.5 / 2.75))*t+.75)+b;
		else if (t < (2.5 / 2.75))return c *(7.5625 *(t-=(2.25 / 2.75))*t+.9375)+b;
		else return c *(7.5625 *(t-=(2.625 / 2.75))*t+.984375)+b;
	}

	Ease.backIn=function(t,b,c,d,s){
		(s===void 0)&& (s=1.70158);
		return c *(t /=d)*t *((s+1)*t-s)+b;
	}

	Ease.backInOut=function(t,b,c,d,s){
		(s===void 0)&& (s=1.70158);
		if ((t /=d *0.5)< 1)return c *0.5 *(t *t *(((s *=(1.525))+1)*t-s))+b;
		return c / 2 *((t-=2)*t *(((s *=(1.525))+1)*t+s)+2)+b;
	}

	Ease.backOut=function(t,b,c,d,s){
		(s===void 0)&& (s=1.70158);
		return c *((t=t / d-1)*t *((s+1)*t+s)+1)+b;
	}

	Ease.elasticIn=function(t,b,c,d,a,p){
		(a===void 0)&& (a=0);
		(p===void 0)&& (p=0);
		var s;
		if (t==0)return b;
		if ((t /=d)==1)return b+c;
		if (!p)p=d *.3;
		if (!a || (c > 0 && a < c)|| (c < 0 && a <-c)){
			a=c;
			s=p / 4;
		}else s=p / Ease.PI2 *Math.asin(c / a);
		return-(a *Math.pow(2,10 *(t-=1))*Math.sin((t *d-s)*Ease.PI2 / p))+b;
	}

	Ease.elasticInOut=function(t,b,c,d,a,p){
		(a===void 0)&& (a=0);
		(p===void 0)&& (p=0);
		var s;
		if (t==0)return b;
		if ((t /=d *0.5)==2)return b+c;
		if (!p)p=d *(.3 *1.5);
		if (!a || (c > 0 && a < c)|| (c < 0 && a <-c)){
			a=c;
			s=p / 4;
		}else s=p / Ease.PI2 *Math.asin(c / a);
		if (t < 1)return-.5 *(a *Math.pow(2,10 *(t-=1))*Math.sin((t *d-s)*Ease.PI2 / p))+b;
		return a *Math.pow(2,-10 *(t-=1))*Math.sin((t *d-s)*Ease.PI2 / p)*.5+c+b;
	}

	Ease.elasticOut=function(t,b,c,d,a,p){
		(a===void 0)&& (a=0);
		(p===void 0)&& (p=0);
		var s;
		if (t==0)return b;
		if ((t /=d)==1)return b+c;
		if (!p)p=d *.3;
		if (!a || (c > 0 && a < c)|| (c < 0 && a <-c)){
			a=c;
			s=p / 4;
		}else s=p / Ease.PI2 *Math.asin(c / a);
		return (a *Math.pow(2,-10 *t)*Math.sin((t *d-s)*Ease.PI2 / p)+c+b);
	}

	Ease.strongIn=function(t,b,c,d){
		return c *(t /=d)*t *t *t *t+b;
	}

	Ease.strongInOut=function(t,b,c,d){
		if ((t /=d *0.5)< 1)return c *0.5 *t *t *t *t *t+b;
		return c *0.5 *((t-=2)*t *t *t *t+2)+b;
	}

	Ease.strongOut=function(t,b,c,d){
		return c *((t=t / d-1)*t *t *t *t+1)+b;
	}

	Ease.sineInOut=function(t,b,c,d){
		return-c *0.5 *(Math.cos(Math.PI *t / d)-1)+b;
	}

	Ease.sineIn=function(t,b,c,d){
		return-c *Math.cos(t / d *Ease.HALF_PI)+c+b;
	}

	Ease.sineOut=function(t,b,c,d){
		return c *Math.sin(t / d *Ease.HALF_PI)+b;
	}

	Ease.quintIn=function(t,b,c,d){
		return c *(t /=d)*t *t *t *t+b;
	}

	Ease.quintInOut=function(t,b,c,d){
		if ((t /=d *0.5)< 1)return c *0.5 *t *t *t *t *t+b;
		return c *0.5 *((t-=2)*t *t *t *t+2)+b;
	}

	Ease.quintOut=function(t,b,c,d){
		return c *((t=t / d-1)*t *t *t *t+1)+b;
	}

	Ease.quartIn=function(t,b,c,d){
		return c *(t /=d)*t *t *t+b;
	}

	Ease.quartInOut=function(t,b,c,d){
		if ((t /=d *0.5)< 1)return c *0.5 *t *t *t *t+b;
		return-c *0.5 *((t-=2)*t *t *t-2)+b;
	}

	Ease.quartOut=function(t,b,c,d){
		return-c *((t=t / d-1)*t *t *t-1)+b;
	}

	Ease.cubicIn=function(t,b,c,d){
		return c *(t /=d)*t *t+b;
	}

	Ease.cubicInOut=function(t,b,c,d){
		if ((t /=d *0.5)< 1)return c *0.5 *t *t *t+b;
		return c *0.5 *((t-=2)*t *t+2)+b;
	}

	Ease.cubicOut=function(t,b,c,d){
		return c *((t=t / d-1)*t *t+1)+b;
	}

	Ease.quadIn=function(t,b,c,d){
		return c *(t /=d)*t+b;
	}

	Ease.quadInOut=function(t,b,c,d){
		if ((t /=d *0.5)< 1)return c *0.5 *t *t+b;
		return-c *0.5 *((--t)*(t-2)-1)+b;
	}

	Ease.quadOut=function(t,b,c,d){
		return-c *(t /=d)*(t-2)+b;
	}

	Ease.expoIn=function(t,b,c,d){
		return (t==0)? b :c *Math.pow(2,10 *(t / d-1))+b-c *0.001;
	}

	Ease.expoInOut=function(t,b,c,d){
		if (t==0)return b;
		if (t==d)return b+c;
		if ((t /=d *0.5)< 1)return c *0.5 *Math.pow(2,10 *(t-1))+b;
		return c *0.5 *(-Math.pow(2,-10 *--t)+2)+b;
	}

	Ease.expoOut=function(t,b,c,d){
		return (t==d)? b+c :c *(-Math.pow(2,-10 *t / d)+1)+b;
	}

	Ease.circIn=function(t,b,c,d){
		return-c *(Math.sqrt(1-(t /=d)*t)-1)+b;
	}

	Ease.circInOut=function(t,b,c,d){
		if ((t /=d *0.5)< 1)return-c *0.5 *(Math.sqrt(1-t *t)-1)+b;
		return c *0.5 *(Math.sqrt(1-(t-=2)*t)+1)+b;
	}

	Ease.circOut=function(t,b,c,d){
		return c *Math.sqrt(1-(t=t / d-1)*t)+b;
	}

	Ease.HALF_PI=Math.PI *0.5;
	Ease.PI2=Math.PI *2;
	return Ease;
})()


//class laya.utils.FontInfo
var FontInfo=(function(){
	function FontInfo(font){
		//this._id=0;
		this._font="14px Arial";
		this._family="Arial";
		this._size=14;
		this._italic=false;
		this._bold=false;
		this._id=FontInfo._gfontID++;
		this.setFont(font || this._font);
	}

	__class(FontInfo,'laya.utils.FontInfo');
	var __proto=FontInfo.prototype;
	__proto.setFont=function(value){
		this._font=value;
		var _words=value.split(' ');
		var l=_words.length;
		if (l < 2){
			if (l==1){
				if (_words[0].indexOf('px')> 0){
					this._size=parseInt(_words[0]);
				}
			}
			return;
		};
		var szpos=-1;
		for (var i=0;i < l;i++){
			if (_words[i].indexOf('px')> 0 || _words[i].indexOf('pt')> 0){
				szpos=i;
				this._size=parseInt(_words[i]);
				if (this._size <=0){
					console.error('font parse error:'+value);
					this._size=14;
				}
				break ;
			}
		};
		var fpos=szpos+1;
		var familys=_words[fpos];
		fpos++;
		for (;fpos < l;fpos++){
			familys+=' '+_words[fpos];
		}
		this._family=(familys.split(','))[0];
		this._italic=_words.indexOf('italic')>=0;
		this._bold=_words.indexOf('bold')>=0;
	}

	FontInfo.Parse=function(font){
		if (font===FontInfo._lastFont){
			return FontInfo._lastFontInfo;
		};
		var r=FontInfo._cache[font];
		if(!r){
			r=FontInfo._cache[font]=new FontInfo(font);
		}
		FontInfo._lastFont=font;
		FontInfo._lastFontInfo=r;
		return r;
	}

	FontInfo.EMPTY=new FontInfo(null);
	FontInfo._cache={};
	FontInfo._gfontID=0;
	FontInfo._lastFont='';
	FontInfo._lastFontInfo=null;
	return FontInfo;
})()


//class laya.utils.Handler
var Handler=(function(){
	function Handler(caller,method,args,once){
		/**执行域(this)。*/
		//this.caller=null;
		/**处理方法。*/
		//this.method=null;
		/**参数。*/
		//this.args=null;
		/**表示是否只执行一次。如果为true，回调后执行recover()进行回收，回收后会被再利用，默认为false 。*/
		this.once=false;
		/**@private */
		this._id=0;
		(once===void 0)&& (once=false);
		this.setTo(caller,method,args,once);
	}

	__class(Handler,'laya.utils.Handler');
	var __proto=Handler.prototype;
	/**
	*设置此对象的指定属性值。
	*@param caller 执行域(this)。
	*@param method 回调方法。
	*@param args 携带的参数。
	*@param once 是否只执行一次，如果为true，执行后执行recover()进行回收。
	*@return 返回 handler 本身。
	*/
	__proto.setTo=function(caller,method,args,once){
		this._id=Handler._gid++;
		this.caller=caller;
		this.method=method;
		this.args=args;
		this.once=once;
		return this;
	}

	/**
	*执行处理器。
	*/
	__proto.run=function(){
		if (this.method==null)return null;
		var id=this._id;
		var result=this.method.apply(this.caller,this.args);
		this._id===id && this.once && this.recover();
		return result;
	}

	/**
	*执行处理器，并携带额外数据。
	*@param data 附加的回调数据，可以是单数据或者Array(作为多参)。
	*/
	__proto.runWith=function(data){
		if (this.method==null)return null;
		var id=this._id;
		if (data==null)
			var result=this.method.apply(this.caller,this.args);
		else if (!this.args && !data.unshift)result=this.method.call(this.caller,data);
		else if (this.args)result=this.method.apply(this.caller,this.args.concat(data));
		else result=this.method.apply(this.caller,data);
		this._id===id && this.once && this.recover();
		return result;
	}

	/**
	*清理对象引用。
	*/
	__proto.clear=function(){
		this.caller=null;
		this.method=null;
		this.args=null;
		return this;
	}

	/**
	*清理并回收到 Handler 对象池内。
	*/
	__proto.recover=function(){
		if (this._id > 0){
			this._id=0;
			Handler._pool.push(this.clear());
		}
	}

	Handler.create=function(caller,method,args,once){
		(once===void 0)&& (once=true);
		if (Handler._pool.length)return Handler._pool.pop().setTo(caller,method,args,once);
		return new Handler(caller,method,args,once);
	}

	Handler._pool=[];
	Handler._gid=1;
	return Handler;
})()


//class laya.utils.HitArea
var HitArea=(function(){
	function HitArea(){
		/**@private */
		this._hit=null;
		/**@private */
		this._unHit=null;
	}

	__class(HitArea,'laya.utils.HitArea');
	var __proto=HitArea.prototype;
	/**
	*检测对象是否包含指定的点。
	*@param x 点的 X 轴坐标值（水平位置）。
	*@param y 点的 Y 轴坐标值（垂直位置）。
	*@return 如果包含指定的点，则值为 true；否则为 false。
	*/
	__proto.contains=function(x,y){
		if (!HitArea._isHitGraphic(x,y,this.hit))return false;
		return !HitArea._isHitGraphic(x,y,this.unHit);
	}

	/**
	*可点击区域，可以设置绘制一系列矢量图作为点击区域（目前只支持圆形，矩形，多边形）
	*/
	__getset(0,__proto,'hit',function(){
		if (!this._hit)this._hit=new Graphics();
		return this._hit;
		},function(value){
		this._hit=value;
	});

	/**
	*不可点击区域，可以设置绘制一系列矢量图作为非点击区域（目前只支持圆形，矩形，多边形）
	*/
	__getset(0,__proto,'unHit',function(){
		if (!this._unHit)this._unHit=new Graphics();
		return this._unHit;
		},function(value){
		this._unHit=value;
	});

	HitArea._isHitGraphic=function(x,y,graphic){
		if (!graphic)return false;
		var cmds=graphic.cmds;
		if (!cmds && graphic._one){
			cmds=HitArea._cmds;
			cmds.length=1;
			cmds[0]=graphic._one;
		}
		if (!cmds)return false;
		var i=0,len=0;
		len=cmds.length;
		var cmd;
		for (i=0;i < len;i++){
			cmd=cmds[i];
			if (!cmd)continue ;
			switch (cmd.cmdID){
				case "Translate":
					x-=cmd.tx;
					y-=cmd.ty;
				}
			if (HitArea._isHitCmd(x,y,cmd))return true;
		}
		return false;
	}

	HitArea._isHitCmd=function(x,y,cmd){
		if (!cmd)return false;
		var rst=false;
		switch (cmd.cmdID){
			case "DrawRect":
				HitArea._rect.setTo(cmd.x,cmd.y,cmd.width,cmd.height);
				rst=HitArea._rect.contains(x,y);
				break ;
			case "DrawCircle":;
				var d=NaN;
				x-=cmd.x;
				y-=cmd.y;
				d=x *x+y *y;
				rst=d < cmd.radius *cmd.radius;
				break ;
			case "DrawPoly":
				x-=cmd.x;
				y-=cmd.y;
				rst=HitArea._ptInPolygon(x,y,cmd.points);
				break ;
			}
		return rst;
	}

	HitArea._ptInPolygon=function(x,y,areaPoints){
		var p=HitArea._ptPoint;
		p.setTo(x,y);
		var nCross=0;
		var p1x=NaN,p1y=NaN,p2x=NaN,p2y=NaN;
		var len=0;
		len=areaPoints.length;
		for (var i=0;i < len;i+=2){
			p1x=areaPoints[i];
			p1y=areaPoints[i+1];
			p2x=areaPoints[(i+2)% len];
			p2y=areaPoints[(i+3)% len];
			if (p1y==p2y)continue ;
			if (p.y < Math.min(p1y,p2y))continue ;
			if (p.y >=Math.max(p1y,p2y))continue ;
			var tx=(p.y-p1y)*(p2x-p1x)/ (p2y-p1y)+p1x;
			if (tx > p.x)nCross++;
		}
		return (nCross % 2==1);
	}

	HitArea._cmds=[];
	__static(HitArea,
	['_rect',function(){return this._rect=new Rectangle();},'_ptPoint',function(){return this._ptPoint=new Point();}
	]);
	return HitArea;
})()


//class laya.utils.Pool
var Pool=(function(){
	function Pool(){}
	__class(Pool,'laya.utils.Pool');
	Pool.getPoolBySign=function(sign){
		return Pool._poolDic[sign] || (Pool._poolDic[sign]=[]);
	}

	Pool.clearBySign=function(sign){
		if (Pool._poolDic[sign])Pool._poolDic[sign].length=0;
	}

	Pool.recover=function(sign,item){
		if (item["__InPool"])return;
		item["__InPool"]=true;
		Pool.getPoolBySign(sign).push(item);
	}

	Pool.recoverByClass=function(instance){
		if (instance){
			var className=instance["__className"] || instance.constructor._$gid;
			if (className)Pool.recover(className,instance);
		}
	}

	Pool._getClassSign=function(cla){
		var className=cla["__className"] || cla["_$gid"];
		if (!className){
			cla["_$gid"]=className=Utils.getGID()+"";
		}
		return className;
	}

	Pool.createByClass=function(cls){
		return Pool.getItemByClass(Pool._getClassSign(cls),cls);
	}

	Pool.getItemByClass=function(sign,cls){
		if (!Pool._poolDic[sign])return new cls();
		var pool=Pool.getPoolBySign(sign);
		if (pool.length){
			var rst=pool.pop();
			rst["__InPool"]=false;
			}else {
			rst=new cls();
		}
		return rst;
	}

	Pool.getItemByCreateFun=function(sign,createFun,caller){
		var pool=Pool.getPoolBySign(sign);
		var rst=pool.length ? pool.pop():createFun.call(caller);
		rst["__InPool"]=false;
		return rst;
	}

	Pool.getItem=function(sign){
		var pool=Pool.getPoolBySign(sign);
		var rst=pool.length ? pool.pop():null;
		if (rst){
			rst["__InPool"]=false;
		}
		return rst;
	}

	Pool.POOLSIGN="__InPool";
	Pool._poolDic={};
	return Pool;
})()


//class laya.utils.RunDriver
var RunDriver=(function(){
	function RunDriver(){}
	__class(RunDriver,'laya.utils.RunDriver');
	RunDriver.getIncludeStr=function(name){
		return null;
	}

	RunDriver.createShaderCondition=function(conditionScript){
		var fn="(function() {return "+conditionScript+";})";
		return Laya._runScript(fn);
	}

	RunDriver.fontMap=[];
	RunDriver.measureText=function(txt,font){
		var isChinese=RunDriver.hanzi.test(txt);
		if (isChinese && RunDriver.fontMap[font]){
			return RunDriver.fontMap[font];
		};
		var ctx=Browser.context;
		ctx.font=font;
		var r=ctx.measureText(txt);
		if (isChinese)RunDriver.fontMap[font]=r;
		return r;
	}

	RunDriver.drawToCanvas=function(sprite,_renderType,canvasWidth,canvasHeight,offsetX,offsetY){
		canvasWidth |=0;canvasHeight |=0;offsetX |=0;offsetY |=0;
		var canvas=new HTMLCanvas();
		var ctx=canvas.getContext('2d');
		canvas.size(canvasWidth,canvasHeight);
		RenderSprite.renders[_renderType]._fun(sprite,ctx,offsetX,offsetY);
		return canvas;
	}

	RunDriver.initRender=function(canvas,w,h){
		Render._context=canvas.getContext('2d');
		canvas.size(w,h);
		return true;
	}

	RunDriver.createParticleTemplate2D=null;
	RunDriver.changeWebGLSize=function(w,h){
	};

	RunDriver.createRenderSprite=function(type,next){
		return new RenderSprite(type,next);
	}

	RunDriver.clear=function(value){
		if (!Render.isConchApp){
			Render._context.clear();
		}
	}

	RunDriver.getTexturePixels=function(value,x,y,width,height){
		return null;
	}

	RunDriver.skinAniSprite=function(){
		return null;
	}

	RunDriver.cancelLoadByUrl=function(url){
	};

	RunDriver.enableNative=null;
	__static(RunDriver,
	['hanzi',function(){return this.hanzi=new RegExp("^[\u4E00-\u9FA5]$");}
	]);
	return RunDriver;
})()


//class laya.utils.SceneUtils
var SceneUtils=(function(){
	var DataWatcher,InitTool;
	function SceneUtils(){}
	__class(SceneUtils,'laya.utils.SceneUtils');
	SceneUtils.getBindFun=function(value){
		var fun=SceneUtils._funMap.get(value);
		if (fun==null){
			var temp="\""+value+"\"";
			temp=temp.replace(/^"\${|}"$/g,"").replace(/\${/g,"\"+").replace(/}/g,"+\"");
			var str="(function(data){if(data==null)return;with(data){try{\nreturn "+temp+"\n}catch(e){}}})";
			fun=Laya._runScript(str);
			SceneUtils._funMap.set(value,fun);
		}
		return fun;
	}

	SceneUtils.createByData=function(root,uiView){
		var tInitTool=InitTool.create();
		root=SceneUtils.createComp(uiView,root,root,null,tInitTool);
		root._setBit(0x08,true);
		if (root.hasOwnProperty("_idMap")){
			root["_idMap"]=tInitTool._idMap;
		}
		if (uiView.animations){
			var anilist=[];
			var animations=uiView.animations;
			var i=0,len=animations.length;
			var tAni;
			var tAniO;
			for (i=0;i < len;i++){
				tAni=new FrameAnimation();
				tAniO=animations[i];
				tAni._setUp(tInitTool._idMap,tAniO);
				root[tAniO.name]=tAni;
				tAni._setControlNode(root);
				switch (tAniO.action){
					case 1:
						tAni.play(0,false);
						break ;
					case 2:
						tAni.play(0,true);
						break ;
					}
				anilist.push(tAni);
			}
			root._aniList=anilist;
		}
		if (root._$componentType==="Scene" && root._width > 0 && uiView.props.hitTestPrior==null && !root.mouseThrough)
			root.hitTestPrior=true;
		tInitTool.beginLoad(root);
		return root;
	}

	SceneUtils.createInitTool=function(){
		return InitTool.create();
	}

	SceneUtils.createComp=function(uiView,comp,view,dataMap,initTool){
		if (uiView.type=="Scene3D"||uiView.type=="Sprite3D"){
			var outBatchSprits=[];
			var scene3D=Laya["Utils3D"]._createSceneByJsonForMaker(uiView,outBatchSprits,initTool);
			if (uiView.type=="Sprite3D")
				Laya["StaticBatchManager"].combine(scene3D,outBatchSprits);
			else
			Laya["StaticBatchManager"].combine(null,outBatchSprits);
			return scene3D;
		}
		comp=comp || SceneUtils.getCompInstance(uiView);
		if (!comp){
			if (uiView.props && uiView.props.runtime)
				console.warn("runtime not found:"+uiView.props.runtime);
			else
			console.warn("can not create:"+uiView.type);
			return null;
		};
		var child=uiView.child;
		if (child){
			var isList=comp["_$componentType"]=="List";
			for (var i=0,n=child.length;i < n;i++){
				var node=child[i];
				if (comp.hasOwnProperty("itemRender")&& (node.props.name=="render" || node.props.renderType==="render")){
					comp["itemRender"]=node;
					}else if (node.type=="Graphic"){
					ClassUtils._addGraphicsToSprite(node,comp);
					}else if (ClassUtils._isDrawType(node.type)){
					ClassUtils._addGraphicToSprite(node,comp,true);
					}else {
					if (isList){
						var arr=[];
						var tChild=SceneUtils.createComp(node,null,view,arr,initTool);
						if (arr.length)
							tChild["_$bindData"]=arr;
						}else {
						tChild=SceneUtils.createComp(node,null,view,dataMap,initTool);
					}
					if (node.type=="Script"){
						if ((tChild instanceof laya.components.Component )){
							comp._addComponentInstance(tChild);
							}else {
							if ("owner" in tChild){
								tChild["owner"]=comp;
								}else if ("target" in tChild){
								tChild["target"]=comp;
							}
						}
						}else if (node.props.renderType=="mask" || node.props.name=="mask"){
						comp.mask=tChild;
						}else {(
						tChild instanceof laya.display.Node )&& comp.addChild(tChild);
					}
				}
			}
		};
		var props=uiView.props;
		for (var prop in props){
			var value=props[prop];
			if ((typeof value=='string')&& (value.indexOf("@node:")>=0 || value.indexOf("@Prefab:")>=0)){
				if (initTool){
					initTool.addNodeRef(comp,prop,value);
				}
			}else
			SceneUtils.setCompValue(comp,prop,value,view,dataMap);
		}
		if (comp._afterInited){
			comp._afterInited();
		}
		if (uiView.compId && initTool && initTool._idMap){
			initTool._idMap[uiView.compId]=comp;
		}
		return comp;
	}

	SceneUtils.setCompValue=function(comp,prop,value,view,dataMap){
		if ((typeof value=='string')&& value.indexOf("${")>-1){
			SceneUtils._sheet || (SceneUtils._sheet=ClassUtils.getClass("laya.data.Table"));
			if (!SceneUtils._sheet){
				console.warn("Can not find class Sheet");
				return;
			}
			if (dataMap){
				dataMap.push(comp,prop,value);
				}else if (view){
				if (value.indexOf("].")==-1){
					value=value.replace(".","[0].");
				};
				var watcher=new DataWatcher(comp,prop,value);
				watcher.exe(view);
				var one,temp;
				var str=value.replace(/\[.*?\]\./g,".");
				while ((one=SceneUtils._parseWatchData.exec(str))!=null){
					var key1=one[1];
					while ((temp=SceneUtils._parseKeyWord.exec(key1))!=null){
						var key2=temp[0];
						var arr=(view._watchMap[key2] || (view._watchMap[key2]=[]));
						arr.push(watcher);
						SceneUtils._sheet.I.notifer.on(key2,view,view.changeData,[key2]);
					}
					arr=(view._watchMap[key1] || (view._watchMap[key1]=[]));
					arr.push(watcher);
					SceneUtils._sheet.I.notifer.on(key1,view,view.changeData,[key1]);
				}
			}
			return;
		}
		if (prop==="var" && view){
			view[value]=comp;
			}else {
			comp[prop]=(value==="true" ? true :(value==="false" ? false :value));
		}
	}

	SceneUtils.getCompInstance=function(json){
		if (json.type=="UIView"){
			if (json.props && json.props.pageData){
				return SceneUtils.createByData(null,json.props.pageData);
			}
		};
		var runtime=(json.props && json.props.runtime)|| json.type;
		var compClass=ClassUtils.getClass(runtime);
		if (!compClass)throw "Can not find class "+runtime;
		if (json.type==="Script" && compClass.prototype._doAwake){
			var comp=Pool.createByClass(compClass);
			comp._destroyed=false;
			return comp;
		}
		if (json.props && json.props.hasOwnProperty("renderType")&& json.props["renderType"]=="instance")
			return compClass["instance"];
		return new compClass();
	}

	SceneUtils._sheet=null;
	__static(SceneUtils,
	['_funMap',function(){return this._funMap=new WeakObject();},'_parseWatchData',function(){return this._parseWatchData=/\${(.*?)}/g;},'_parseKeyWord',function(){return this._parseKeyWord=/[a-zA-Z_][a-zA-Z0-9_]*(?:(?:\.[a-zA-Z_][a-zA-Z0-9_]*)+)/g;}
	]);
	SceneUtils.__init$=function(){
		/**
		*@private 场景辅助类
		*/
		//class DataWatcher
		DataWatcher=(function(){
			function DataWatcher(comp,prop,value){
				this.comp=null;
				this.prop=null;
				this.value=null;
				this.comp=comp;
				this.prop=prop;
				this.value=value;
			}
			__class(DataWatcher,'');
			var __proto=DataWatcher.prototype;
			__proto.exe=function(view){
				var fun=SceneUtils.getBindFun(this.value);
				this.comp[this.prop]=fun.call(this,view);
			}
			return DataWatcher;
		})()
		/**
		*@private 场景辅助类
		*/
		//class InitTool
		InitTool=(function(){
			function InitTool(){
				/**@private */
				this._nodeRefList=null;
				/**@private */
				this._initList=null;
				this._loadList=null;
				/**@private */
				this._idMap=null;
				this._scene=null;
			}
			__class(InitTool,'');
			var __proto=InitTool.prototype;
			//TODO:coverage
			__proto.reset=function(){
				this._nodeRefList=null;
				this._initList=null;
				this._idMap=null;
				this._loadList=null;
				this._scene=null;
			}
			//TODO:coverage
			__proto.recover=function(){
				this.reset();
				Pool.recover("InitTool",this);
			}
			//TODO:coverage
			__proto.addLoadRes=function(url,type){
				if (!this._loadList)this._loadList=[];
				if (!type){
					this._loadList.push(url);
					}else {
					this._loadList.push({url:url,type:type});
				}
			}
			//TODO:coverage
			__proto.addNodeRef=function(node,prop,referStr){
				if (!this._nodeRefList)this._nodeRefList=[];
				this._nodeRefList.push([node,prop,referStr]);
				if (referStr.indexOf("@Prefab:")>=0){
					this.addLoadRes(referStr.replace("@Prefab:",""),"prefab");
				}
			}
			//TODO:coverage
			__proto.setNodeRef=function(){
				if (!this._nodeRefList)return;
				if (!this._idMap){
					this._nodeRefList=null;
					return;
				};
				var i=0,len=0;
				len=this._nodeRefList.length;
				var tRefInfo;
				for (i=0;i < len;i++){
					tRefInfo=this._nodeRefList[i];
					tRefInfo[0][tRefInfo[1]]=this.getReferData(tRefInfo[2]);
				}
				this._nodeRefList=null;
			}
			//TODO:coverage
			__proto.getReferData=function(referStr){
				if (referStr.indexOf("@Prefab:")>=0){
					var prefab;
					prefab=Loader.getRes(referStr.replace("@Prefab:",""));
					return prefab;
					}else if (referStr.indexOf("@arr:")>=0){
					referStr=referStr.replace("@arr:","");
					var list;
					list=referStr.split(",");
					var i=0,len=0;
					var tStr;
					len=list.length;
					for (i=0;i < len;i++){
						tStr=list[i];
						if (tStr){
							list[i]=this._idMap[tStr.replace("@node:","")];
							}else {
							list[i]=null;
						}
					}
					return list;
					}else {
					return this._idMap[referStr.replace("@node:","")];
				}
			}
			//TODO:coverage
			__proto.addInitItem=function(item){
				if (!this._initList)this._initList=[];
				this._initList.push(item);
			}
			//TODO:coverage
			__proto.doInits=function(){
				if (!this._initList)return;
				this._initList=null;
			}
			//TODO:coverage
			__proto.finish=function(){
				this.setNodeRef();
				this.doInits();
				this._scene._setBit(0x08,false);
				if (this._scene.parent && this._scene.parent.activeInHierarchy && this._scene.active)this._scene._activeHierarchy();
				this._scene.event("onViewCreated");
				this.recover();
			}
			//TODO:coverage
			__proto.beginLoad=function(scene){
				this._scene=scene;
				if (!this._loadList || this._loadList.length < 1){
					this.finish();
					}else {
					Laya.loader.load(this._loadList,Handler.create(this,this.finish));
				}
			}
			InitTool.create=function(){
				var tool=Pool.getItemByClass("InitTool",InitTool);
				tool._idMap=[];
				return tool;
			}
			return InitTool;
		})()
	}

	return SceneUtils;
})()


//class laya.utils.Stat
var Stat=(function(){
	function Stat(){}
	__class(Stat,'laya.utils.Stat');
	/**
	*点击性能统计显示区域的处理函数。
	*/
	__getset(1,Stat,'onclick',null,function(fn){
		if (Stat._sp){
			Stat._sp.on("click",Stat._sp,fn);
		}
		if (Stat._canvas){
			Stat._canvas.source.onclick=fn;
			Stat._canvas.source.style.pointerEvents='';
		}
	});

	Stat.show=function(x,y){
		(x===void 0)&& (x=0);
		(y===void 0)&& (y=0);
		if (!Browser.onMiniGame && !Browser.onLimixiu)Stat._useCanvas=true;
		Stat._show=true;
		Stat._fpsData.length=60;
		if (Render.isConchApp){
			Stat._view[0]={title:"FPS",value:"_fpsStr",color:"yellow",units:"int"};
			}else {
			Stat._view[0]={title:"FPS(Canvas)",value:"_fpsStr",color:"yellow",units:"int"};
		}
		Stat._view[1]={title:"Sprite",value:"_spriteStr",color:"white",units:"int"};
		Stat._view[2]={title:"DrawCall",value:"drawCall",color:"white",units:"int"};
		Stat._view[3]={title:"CurMem",value:"currentMemorySize",color:"yellow",units:"M"};
		if (Render.isWebGL){
			Stat._view[4]={title:"Shader",value:"shaderCall",color:"white",units:"int"};
			if (!Render.is3DMode){
				Stat._view[0].title="FPS(WebGL)";
				Stat._view[5]={title:"Canvas",value:"_canvasStr",color:"white",units:"int"};
				}else {
				Stat._view[0].title="FPS(3D)";
				Stat._view[5]={title:"TriFaces",value:"trianglesFaces",color:"white",units:"int"};
				Stat._view[6]={title:"treeNodeColl",value:"treeNodeCollision",color:"white",units:"int"};
				Stat._view[7]={title:"treeSpriteColl",value:"treeSpriteCollision",color:"white",units:"int"};
			}
		}else {}
		if (Stat._useCanvas){
			Stat.createUIPre(x,y);
		}else
		Stat.createUI(x,y);
		Stat.enable();
	}

	Stat.createUIPre=function(x,y){
		var pixel=Browser.pixelRatio;
		Stat._width=pixel *130;
		Stat._vx=pixel *75;
		Stat._height=pixel *(Stat._view.length *12+3 *pixel)+4;
		Stat._fontSize=12 *pixel;
		for (var i=0;i < Stat._view.length;i++){
			Stat._view[i].x=4;
			Stat._view[i].y=i *Stat._fontSize+2 *pixel;
		}
		if (Render.isConchApp){
			Stat._sp=new Sprite();
			Stat._titleSp=new Sprite();
			Stat._bgSp=new Sprite();
			Stat._bgSp.graphics.drawRect(x,y,Stat._width,Stat._height,"#969696");
			Stat._bgSp.alpha=0.8;
			Stat._sp.zOrder=100000;
			Stat._titleSp.zOrder=100000;
			Stat._bgSp.zOrder=100000;
			Stat._bgSp.addChild(Stat._sp);
			Stat._bgSp.addChild(Stat._titleSp);
			Laya.stage.addChild(Stat._bgSp);
			}else {
			if (!Stat._canvas){
				Stat._canvas=new HTMLCanvas(true);
				Stat._canvas.size(Stat._width,Stat._height);
				Stat._ctx=Stat._canvas.getContext('2d');
				Stat._ctx.textBaseline="top";
				Stat._ctx.font=Stat._fontSize+"px Arial";
				Stat._canvas.source.style.cssText="pointer-events:none;background:rgba(150,150,150,0.8);z-index:100000;position: absolute;direction:ltr;left:"+x+"px;top:"+y+"px;width:"+(Stat._width / pixel)+"px;height:"+(Stat._height / pixel)+"px;";
			}
			Browser.container.appendChild(Stat._canvas.source);
		}
		Stat._first=true;
		Stat.loop();
		Stat._first=false;
	}

	Stat.createUI=function(x,y){
		var stat=Stat._sp;
		var pixel=Browser.pixelRatio;
		if (!stat){
			stat=new Sprite();
			Stat._leftText=new Text();
			Stat._leftText.pos(5,5);
			Stat._leftText.color="#ffffff";
			stat.addChild(Stat._leftText);
			Stat._txt=new Text();
			Stat._txt.pos(80 *pixel,5);
			Stat._txt.color="#ffffff";
			stat.addChild(Stat._txt);
			Stat._sp=stat;
		}
		stat.pos(x,y);
		var text="";
		for (var i=0;i < Stat._view.length;i++){
			var one=Stat._view[i];
			text+=one.title+"\n";
		}
		Stat._leftText.text=text;
		var width=pixel *138;
		var height=pixel *(Stat._view.length *12+3 *pixel)+4;
		Stat._txt.fontSize=Stat._fontSize *pixel;
		Stat._leftText.fontSize=Stat._fontSize *pixel;
		stat.size(width,height);
		stat.graphics.clear();
		stat.graphics.alpha(0.5);
		stat.graphics.drawRect(0,0,width,height,"#999999");
		stat.graphics.alpha(2);
		Stat.loop();
	}

	Stat.enable=function(){
		Laya.systemTimer.frameLoop(1,Stat,Stat.loop);
	}

	Stat.hide=function(){
		Stat._show=false;
		Laya.systemTimer.clear(Stat,Stat.loop);
		if (Stat._canvas){
			Browser.removeElement(Stat._canvas.source);
		}
	}

	Stat.clear=function(){
		Stat.trianglesFaces=Stat.drawCall=Stat.shaderCall=Stat.spriteCount=Stat.spriteRenderUseCacheCount=Stat.treeNodeCollision=Stat.treeSpriteCollision=Stat.canvasNormal=Stat.canvasBitmap=Stat.canvasReCache=0;
	}

	Stat.loop=function(){
		Stat._count++;
		var timer=Browser.now();
		if (timer-Stat._timer < 1000)return;
		var count=Stat._count;
		Stat.FPS=Math.round((count *1000)/ (timer-Stat._timer));
		if (Stat._show){
			Stat.trianglesFaces=Math.round(Stat.trianglesFaces / count);
			if (!Stat._useCanvas){
				Stat.drawCall=Math.round(Stat.drawCall / count)-1;
				Stat.shaderCall=Math.round(Stat.shaderCall / count);
				Stat.spriteCount=Math.round(Stat.spriteCount / count)-4;
				}else {
				Stat.drawCall=Math.round(Stat.drawCall / count);
				Stat.shaderCall=Math.round(Stat.shaderCall / count);
				Stat.spriteCount=Math.round(Stat.spriteCount / count)-1;
			}
			Stat.spriteRenderUseCacheCount=Math.round(Stat.spriteRenderUseCacheCount / count);
			Stat.canvasNormal=Math.round(Stat.canvasNormal / count);
			Stat.canvasBitmap=Math.round(Stat.canvasBitmap / count);
			Stat.canvasReCache=Math.ceil(Stat.canvasReCache / count);
			Stat.treeNodeCollision=Math.round(Stat.treeNodeCollision / count);
			Stat.treeSpriteCollision=Math.round(Stat.treeSpriteCollision / count);
			var delay=Stat.FPS > 0 ? Math.floor(1000 / Stat.FPS).toString():" ";
			Stat._fpsStr=Stat.FPS+(Stat.renderSlow ? " slow" :"")+" "+delay;
			Stat._spriteStr=Stat.spriteCount+(Stat.spriteRenderUseCacheCount ? ("/"+Stat.spriteRenderUseCacheCount):'');
			Stat._canvasStr=Stat.canvasReCache+"/"+Stat.canvasNormal+"/"+Stat.canvasBitmap;
			Stat.currentMemorySize=ResourceManager.systemResourceManager.memorySize;
			if (Stat._useCanvas){
				Stat.renderInfoPre();
			}else
			Stat.renderInfo();
			Stat.clear();
		}
		Stat._count=0;
		Stat._timer=timer;
	}

	Stat.renderInfoPre=function(){
		var i=0;
		var one;
		var value;
		if (Render.isConchApp){
			Stat._sp.graphics.clear();
			for (i=0;i < Stat._view.length;i++){
				one=Stat._view[i];
				if (Stat._first){
					Stat._titleSp.graphics.fillText(one.title,one.x,one.y,Stat._fontSize+"px Arial","#ffffff","left");
				}
				value=Stat[one.value];
				(one.units=="M")&& (value=Math.floor(value / (1024 *1024)*100)/ 100+" M");
				Stat._sp.graphics.fillText(value+"",one.x+Stat._vx,one.y,Stat._fontSize+"px Arial",one.color,"left");
			}
			}else {
			if (Stat._canvas){
				var ctx=Stat._ctx;
				ctx.clearRect(Stat._first ? 0 :Stat._vx,0,Stat._width,Stat._height);
				for (i=0;i < Stat._view.length;i++){
					one=Stat._view[i];
					if (Stat._first){
						ctx.fillStyle="white";
						ctx.fillText(one.title,one.x,one.y);
					}
					ctx.fillStyle=one.color;
					value=Stat[one.value];
					(one.units=="M")&& (value=Math.floor(value / (1024 *1024)*100)/ 100+" M");
					ctx.fillText(value+"",one.x+Stat._vx,one.y);
				}
			}
		}
	}

	Stat.renderInfo=function(){
		var text="";
		for (var i=0;i < Stat._view.length;i++){
			var one=Stat._view[i];
			var value=Stat[one.value];
			(one.units=="M")&& (value=Math.floor(value / (1024 *1024)*100)/ 100+" M");
			(one.units=="K")&& (value=Math.floor(value / (1024)*100)/ 100+" K");
			text+=value+"\n";
		}
		Stat._txt.text=text;
	}

	Stat.FPS=0;
	Stat.loopCount=0;
	Stat.shaderCall=0;
	Stat.drawCall=0;
	Stat.trianglesFaces=0;
	Stat.spriteCount=0;
	Stat.spriteRenderUseCacheCount=0;
	Stat.treeNodeCollision=0;
	Stat.treeSpriteCollision=0;
	Stat.canvasNormal=0;
	Stat.canvasBitmap=0;
	Stat.canvasReCache=0;
	Stat.renderSlow=false;
	Stat.currentMemorySize=0;
	Stat._fpsStr=null;
	Stat._canvasStr=null;
	Stat._spriteStr=null;
	Stat._fpsData=[];
	Stat._timer=0;
	Stat._count=0;
	Stat._view=[];
	Stat._fontSize=12;
	Stat._txt=null;
	Stat._leftText=null;
	Stat._sp=null;
	Stat._titleSp=null;
	Stat._bgSp=null;
	Stat._show=false;
	Stat._useCanvas=false;
	Stat._canvas=null;
	Stat._ctx=null;
	Stat._first=false;
	Stat._vx=NaN;
	Stat._width=0;
	Stat._height=100;
	return Stat;
})()


//class laya.utils.Timer
var Timer=(function(){
	var TimerHandler;
	function Timer(autoActive){
		/**时针缩放。*/
		this.scale=1;
		/**当前的帧数。*/
		this.currFrame=0;
		/**@private 两帧之间的时间间隔,单位毫秒。*/
		this._delta=0;
		/**@private */
		this._map=[];
		/**@private */
		this._handlers=[];
		/**@private */
		this._temp=[];
		/**@private */
		this._count=0;
		this.currTimer=Browser.now();
		this._lastTimer=Browser.now();
		(autoActive===void 0)&& (autoActive=true);
		autoActive && Laya.systemTimer && Laya.systemTimer.frameLoop(1,this,this._update);
	}

	__class(Timer,'laya.utils.Timer');
	var __proto=Timer.prototype;
	/**
	*@private
	*帧循环处理函数。
	*/
	__proto._update=function(){
		if (this.scale <=0){
			this._lastTimer=Browser.now();
			return;
		};
		var frame=this.currFrame=this.currFrame+this.scale;
		var now=Browser.now();
		this._delta=(now-this._lastTimer)*this.scale;
		var timer=this.currTimer=this.currTimer+this._delta;
		this._lastTimer=now;
		var handlers=this._handlers;
		this._count=0;
		for (var i=0,n=handlers.length;i < n;i++){
			var handler=handlers[i];
			if (handler.method!==null){
				var t=handler.userFrame ? frame :timer;
				if (t >=handler.exeTime){
					if (handler.repeat){
						if (!handler.jumpFrame){
							handler.exeTime+=handler.delay;
							handler.run(false);
							if (t > handler.exeTime){
								handler.exeTime+=Math.ceil((t-handler.exeTime)/ handler.delay)*handler.delay;
							}
							}else {
							while (t >=handler.exeTime){
								handler.exeTime+=handler.delay;
								handler.run(false);
							}
						}
						}else {
						handler.run(true);
					}
				}
				}else {
				this._count++;
			}
		}
		if (this._count > 30 || frame % 200===0)this._clearHandlers();
	}

	/**@private */
	__proto._clearHandlers=function(){
		var handlers=this._handlers;
		for (var i=0,n=handlers.length;i < n;i++){
			var handler=handlers[i];
			if (handler.method!==null)this._temp.push(handler);
			else this._recoverHandler(handler);
		}
		this._handlers=this._temp;
		handlers.length=0;
		this._temp=handlers;
	}

	/**@private */
	__proto._recoverHandler=function(handler){
		if (this._map[handler.key]==handler)this._map[handler.key]=null;
		handler.clear();
		Timer._pool.push(handler);
	}

	/**@private */
	__proto._create=function(useFrame,repeat,delay,caller,method,args,coverBefore){
		if (!delay){
			method.apply(caller,args);
			return null;
		}
		if (coverBefore){
			var handler=this._getHandler(caller,method);
			if (handler){
				handler.repeat=repeat;
				handler.userFrame=useFrame;
				handler.delay=delay;
				handler.caller=caller;
				handler.method=method;
				handler.args=args;
				handler.exeTime=delay+(useFrame ? this.currFrame :this.currTimer+Browser.now()-this._lastTimer);
				return handler;
			}
		}
		handler=Timer._pool.length > 0 ? Timer._pool.pop():new TimerHandler();
		handler.repeat=repeat;
		handler.userFrame=useFrame;
		handler.delay=delay;
		handler.caller=caller;
		handler.method=method;
		handler.args=args;
		handler.exeTime=delay+(useFrame ? this.currFrame :this.currTimer+Browser.now()-this._lastTimer);
		this._indexHandler(handler);
		this._handlers.push(handler);
		return handler;
	}

	/**@private */
	__proto._indexHandler=function(handler){
		var caller=handler.caller;
		var method=handler.method;
		var cid=caller ? caller.$_GID || (caller.$_GID=Utils.getGID()):0;
		var mid=method.$_TID || (method.$_TID=(Timer._mid++)*100000);
		handler.key=cid+mid;
		this._map[handler.key]=handler;
	}

	/**
	*定时执行一次。
	*@param delay 延迟时间(单位为毫秒)。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*@param args 回调参数。
	*@param coverBefore 是否覆盖之前的延迟执行，默认为 true 。
	*/
	__proto.once=function(delay,caller,method,args,coverBefore){
		(coverBefore===void 0)&& (coverBefore=true);
		this._create(false,false,delay,caller,method,args,coverBefore);
	}

	/**
	*定时重复执行。
	*@param delay 间隔时间(单位毫秒)。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*@param args 回调参数。
	*@param coverBefore 是否覆盖之前的延迟执行，默认为 true 。
	*@param jumpFrame 时钟是否跳帧。基于时间的循环回调，单位时间间隔内，如能执行多次回调，出于性能考虑，引擎默认只执行一次，设置jumpFrame=true后，则回调会连续执行多次
	*/
	__proto.loop=function(delay,caller,method,args,coverBefore,jumpFrame){
		(coverBefore===void 0)&& (coverBefore=true);
		(jumpFrame===void 0)&& (jumpFrame=false);
		var handler=this._create(false,true,delay,caller,method,args,coverBefore);
		if (handler)handler.jumpFrame=jumpFrame;
	}

	/**
	*定时执行一次(基于帧率)。
	*@param delay 延迟几帧(单位为帧)。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*@param args 回调参数。
	*@param coverBefore 是否覆盖之前的延迟执行，默认为 true 。
	*/
	__proto.frameOnce=function(delay,caller,method,args,coverBefore){
		(coverBefore===void 0)&& (coverBefore=true);
		this._create(true,false,delay,caller,method,args,coverBefore);
	}

	/**
	*定时重复执行(基于帧率)。
	*@param delay 间隔几帧(单位为帧)。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*@param args 回调参数。
	*@param coverBefore 是否覆盖之前的延迟执行，默认为 true 。
	*/
	__proto.frameLoop=function(delay,caller,method,args,coverBefore){
		(coverBefore===void 0)&& (coverBefore=true);
		this._create(true,true,delay,caller,method,args,coverBefore);
	}

	/**返回统计信息。*/
	__proto.toString=function(){
		return " handlers:"+this._handlers.length+" pool:"+Timer._pool.length;
	}

	/**
	*清理定时器。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*/
	__proto.clear=function(caller,method){
		var handler=this._getHandler(caller,method);
		if (handler){
			this._map[handler.key]=null;
			handler.key=0;
			handler.clear();
		}
	}

	/**
	*清理对象身上的所有定时器。
	*@param caller 执行域(this)。
	*/
	__proto.clearAll=function(caller){
		if (!caller)return;
		for (var i=0,n=this._handlers.length;i < n;i++){
			var handler=this._handlers[i];
			if (handler.caller===caller){
				this._map[handler.key]=null;
				handler.key=0;
				handler.clear();
			}
		}
	}

	/**@private */
	__proto._getHandler=function(caller,method){
		var cid=caller ? caller.$_GID || (caller.$_GID=Utils.getGID()):0;
		var mid=method.$_TID || (method.$_TID=(Timer._mid++)*100000);
		return this._map[cid+mid];
	}

	/**
	*延迟执行。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*@param args 回调参数。
	*/
	__proto.callLater=function(caller,method,args){
		CallLater.I.callLater(caller,method,args);
	}

	/**
	*立即执行 callLater 。
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*/
	__proto.runCallLater=function(caller,method){
		CallLater.I.runCallLater(caller,method);
	}

	/**
	*立即提前执行定时器，执行之后从队列中删除
	*@param caller 执行域(this)。
	*@param method 定时器回调函数。
	*/
	__proto.runTimer=function(caller,method){
		var handler=this._getHandler(caller,method);
		if (handler && handler.method !=null){
			this._map[handler.key]=null;
			handler.run(true);
		}
	}

	/**
	*暂停时钟
	*/
	__proto.pause=function(){
		this.scale=0;
	}

	/**
	*恢复时钟
	*/
	__proto.resume=function(){
		this.scale=1;
	}

	/**两帧之间的时间间隔,单位毫秒。*/
	__getset(0,__proto,'delta',function(){
		return this._delta;
	});

	Timer._pool=[];
	Timer._mid=1;
	Timer.__init$=function(){
		/**@private */
		//class TimerHandler
		TimerHandler=(function(){
			function TimerHandler(){
				this.key=0;
				this.repeat=false;
				this.delay=0;
				this.userFrame=false;
				this.exeTime=0;
				this.caller=null;
				this.method=null;
				this.args=null;
				this.jumpFrame=false;
			}
			__class(TimerHandler,'');
			var __proto=TimerHandler.prototype;
			__proto.clear=function(){
				this.caller=null;
				this.method=null;
				this.args=null;
			}
			__proto.run=function(withClear){
				var caller=this.caller;
				if (caller && caller.destroyed)return this.clear();
				var method=this.method;
				var args=this.args;
				withClear && this.clear();
				if (method==null)return;
				args ? method.apply(caller,args):method.call(caller);
			}
			return TimerHandler;
		})()
	}

	return Timer;
})()


//class laya.utils.Tween
var Tween=(function(){
	function Tween(){
		/**@private */
		//this._complete=null;
		/**@private */
		//this._target=null;
		/**@private */
		//this._ease=null;
		/**@private */
		//this._props=null;
		/**@private */
		//this._duration=0;
		/**@private */
		//this._delay=0;
		/**@private */
		//this._startTimer=0;
		/**@private */
		//this._usedTimer=0;
		/**@private */
		//this._usedPool=false;
		/**@private */
		//this._delayParam=null;
		/**@private 唯一标识，TimeLintLite用到*/
		this.gid=0;
		/**更新回调，缓动数值发生变化时，回调变化的值*/
		//this.update=null;
		/**重播次数*/
		this.repeat=1;
		/**当前播放次数*/
		this._count=0;
	}

	__class(Tween,'laya.utils.Tween');
	var __proto=Tween.prototype;
	/**
	*缓动对象的props属性到目标值。
	*@param target 目标对象(即将更改属性值的对象)。
	*@param props 变化的属性列表，比如{x:100,y:20,ease:Ease.backOut,complete:Handler.create(this,onComplete),update:new Handler(this,onComplete)}。
	*@param duration 花费的时间，单位毫秒。
	*@param ease 缓动类型，默认为匀速运动。
	*@param complete 结束回调函数。
	*@param delay 延迟执行时间。
	*@param coverBefore 是否覆盖之前的缓动。
	*@return 返回Tween对象。
	*/
	__proto.to=function(target,props,duration,ease,complete,delay,coverBefore){
		(delay===void 0)&& (delay=0);
		(coverBefore===void 0)&& (coverBefore=false);
		return this._create(target,props,duration,ease,complete,delay,coverBefore,true,false,true);
	}

	/**
	*从props属性，缓动到当前状态。
	*@param target 目标对象(即将更改属性值的对象)。
	*@param props 变化的属性列表，比如{x:100,y:20,ease:Ease.backOut,complete:Handler.create(this,onComplete),update:new Handler(this,onComplete)}。
	*@param duration 花费的时间，单位毫秒。
	*@param ease 缓动类型，默认为匀速运动。
	*@param complete 结束回调函数。
	*@param delay 延迟执行时间。
	*@param coverBefore 是否覆盖之前的缓动。
	*@return 返回Tween对象。
	*/
	__proto.from=function(target,props,duration,ease,complete,delay,coverBefore){
		(delay===void 0)&& (delay=0);
		(coverBefore===void 0)&& (coverBefore=false);
		return this._create(target,props,duration,ease,complete,delay,coverBefore,false,false,true);
	}

	/**@private */
	__proto._create=function(target,props,duration,ease,complete,delay,coverBefore,isTo,usePool,runNow){
		if (!target)throw new Error("Tween:target is null");
		this._target=target;
		this._duration=duration;
		this._ease=ease || props.ease || Tween.easeNone;
		this._complete=complete || props.complete;
		this._delay=delay;
		this._props=[];
		this._usedTimer=0;
		this._startTimer=Browser.now();
		this._usedPool=usePool;
		this._delayParam=null;
		this.update=props.update;
		var gid=(target.$_GID || (target.$_GID=Utils.getGID()));
		if (!Tween.tweenMap[gid]){
			Tween.tweenMap[gid]=[this];
			}else {
			if (coverBefore)Tween.clearTween(target);
			Tween.tweenMap[gid].push(this);
		}
		if (runNow){
			if (delay <=0)this.firstStart(target,props,isTo);
			else{
				this._delayParam=[target,props,isTo];
				Laya.timer.once(delay,this,this.firstStart,this._delayParam);
			}
			}else {
			this._initProps(target,props,isTo);
		}
		return this;
	}

	__proto.firstStart=function(target,props,isTo){
		this._delayParam=null;
		if (target.destroyed){
			this.clear();
			return;
		}
		this._initProps(target,props,isTo);
		this._beginLoop();
	}

	__proto._initProps=function(target,props,isTo){
		for (var p in props){
			if ((typeof (target[p])=='number')){
				var start=isTo ? target[p] :props[p];
				var end=isTo ? props[p] :target[p];
				this._props.push([p,start,end-start]);
				if (!isTo)target[p]=start;
			}
		}
	}

	__proto._beginLoop=function(){
		Laya.timer.frameLoop(1,this,this._doEase);
	}

	/**执行缓动**/
	__proto._doEase=function(){
		this._updateEase(Browser.now());
	}

	/**@private */
	__proto._updateEase=function(time){
		var target=this._target;
		if (!target)return;
		if (target.destroyed)return Tween.clearTween(target);
		var usedTimer=this._usedTimer=time-this._startTimer-this._delay;
		if (usedTimer < 0)return;
		if (usedTimer >=this._duration)return this.complete();
		var ratio=usedTimer > 0 ? this._ease(usedTimer,0,1,this._duration):0;
		var props=this._props;
		for (var i=0,n=props.length;i < n;i++){
			var prop=props[i];
			target[prop[0]]=prop[1]+(ratio *prop[2]);
		}
		if (this.update)this.update.run();
	}

	/**
	*立即结束缓动并到终点。
	*/
	__proto.complete=function(){
		if (!this._target)return;
		Laya.timer.runTimer(this,this.firstStart);
		var target=this._target;
		var props=this._props;
		var handler=this._complete;
		for (var i=0,n=props.length;i < n;i++){
			var prop=props[i];
			target[prop[0]]=prop[1]+prop[2];
		}
		if (this.update)this.update.run();
		this._count++;
		if (this._count >=this.repeat){
			this.clear();
			handler && handler.run();
			}else {
			this.restart();
		}
	}

	/**
	*暂停缓动，可以通过resume或restart重新开始。
	*/
	__proto.pause=function(){
		Laya.timer.clear(this,this._beginLoop);
		Laya.timer.clear(this,this._doEase);
		Laya.timer.clear(this,this.firstStart);
		var time=Browser.now();
		var dTime=NaN;
		dTime=time-this._startTimer-this._delay;
		if (dTime < 0){
			this._usedTimer=dTime;
		}
	}

	/**
	*设置开始时间。
	*@param startTime 开始时间。
	*/
	__proto.setStartTime=function(startTime){
		this._startTimer=startTime;
	}

	/**
	*停止并清理当前缓动。
	*/
	__proto.clear=function(){
		if (this._target){
			this._remove();
			this._clear();
		}
	}

	/**
	*@private
	*/
	__proto._clear=function(){
		this.pause();
		Laya.timer.clear(this,this.firstStart);
		this._complete=null;
		this._target=null;
		this._ease=null;
		this._props=null;
		this._delayParam=null;
		if (this._usedPool){
			this.update=null;
			Pool.recover("tween",this);
		}
	}

	/**回收到对象池。*/
	__proto.recover=function(){
		this._usedPool=true;
		this._clear();
	}

	__proto._remove=function(){
		var tweens=Tween.tweenMap[this._target.$_GID];
		if (tweens){
			for (var i=0,n=tweens.length;i < n;i++){
				if (tweens[i]===this){
					tweens.splice(i,1);
					break ;
				}
			}
		}
	}

	/**
	*重新开始暂停的缓动。
	*/
	__proto.restart=function(){
		this.pause();
		this._usedTimer=0;
		this._startTimer=Browser.now();
		if (this._delayParam){
			Laya.timer.once(this._delay,this,this.firstStart,this._delayParam);
			return;
		};
		var props=this._props;
		for (var i=0,n=props.length;i < n;i++){
			var prop=props[i];
			this._target[prop[0]]=prop[1];
		}
		Laya.timer.once(this._delay,this,this._beginLoop);
	}

	/**
	*恢复暂停的缓动。
	*/
	__proto.resume=function(){
		if (this._usedTimer >=this._duration)return;
		this._startTimer=Browser.now()-this._usedTimer-this._delay;
		if (this._delayParam){
			if (this._usedTimer < 0){
				Laya.timer.once(-this._usedTimer,this,this.firstStart,this._delayParam);
				}else{
				this.firstStart.apply(this,this._delayParam);
			}
			}else{
			this._beginLoop();
		}
	}

	/**设置当前执行比例**/
	__getset(0,__proto,'progress',null,function(v){
		var uTime=v *this._duration;
		this._startTimer=Browser.now()-this._delay-uTime;
	});

	Tween.to=function(target,props,duration,ease,complete,delay,coverBefore,autoRecover){
		(delay===void 0)&& (delay=0);
		(coverBefore===void 0)&& (coverBefore=false);
		(autoRecover===void 0)&& (autoRecover=true);
		return Pool.getItemByClass("tween",Tween)._create(target,props,duration,ease,complete,delay,coverBefore,true,autoRecover,true);
	}

	Tween.from=function(target,props,duration,ease,complete,delay,coverBefore,autoRecover){
		(delay===void 0)&& (delay=0);
		(coverBefore===void 0)&& (coverBefore=false);
		(autoRecover===void 0)&& (autoRecover=true);
		return Pool.getItemByClass("tween",Tween)._create(target,props,duration,ease,complete,delay,coverBefore,false,autoRecover,true);
	}

	Tween.clearAll=function(target){
		if (!target || !target.$_GID)return;
		var tweens=Tween.tweenMap[target.$_GID];
		if (tweens){
			for (var i=0,n=tweens.length;i < n;i++){
				tweens[i]._clear();
			}
			tweens.length=0;
		}
	}

	Tween.clear=function(tween){
		tween.clear();
	}

	Tween.clearTween=function(target){
		Tween.clearAll(target);
	}

	Tween.easeNone=function(t,b,c,d){
		return c *t / d+b;
	}

	Tween.tweenMap=[];
	return Tween;
})()


//class laya.utils.Utils
var Utils=(function(){
	function Utils(){}
	__class(Utils,'laya.utils.Utils');
	Utils.toRadian=function(angle){
		return angle *Utils._pi2;
	}

	Utils.toAngle=function(radian){
		return radian *Utils._pi;
	}

	Utils.toHexColor=function(color){
		if (color < 0 || isNaN(color))return null;
		var str=color.toString(16);
		while (str.length < 6)str="0"+str;
		return "#"+str;
	}

	Utils.getGID=function(){
		return Utils._gid++;
	}

	Utils.concatArray=function(source,array){
		if (!array)return source;
		if (!source)return array;
		var i=0,len=array.length;
		for (i=0;i < len;i++){
			source.push(array[i]);
		}
		return source;
	}

	Utils.clearArray=function(array){
		if (!array)return array;
		array.length=0;
		return array;
	}

	Utils.copyArray=function(source,array){
		source || (source=[]);
		if (!array)return source;
		source.length=array.length;
		var i=0,len=array.length;
		for (i=0;i < len;i++){
			source[i]=array[i];
		}
		return source;
	}

	Utils.getGlobalRecByPoints=function(sprite,x0,y0,x1,y1){
		var newLTPoint;
		newLTPoint=Point.create().setTo(x0,y0);
		newLTPoint=sprite.localToGlobal(newLTPoint);
		var newRBPoint;
		newRBPoint=Point.create().setTo(x1,y1);
		newRBPoint=sprite.localToGlobal(newRBPoint);
		var rst=Rectangle._getWrapRec([newLTPoint.x,newLTPoint.y,newRBPoint.x,newRBPoint.y]);
		newLTPoint.recover();
		newRBPoint.recover();
		return rst;
	}

	Utils.getGlobalPosAndScale=function(sprite){
		return Utils.getGlobalRecByPoints(sprite,0,0,1,1);
	}

	Utils.bind=function(fun,scope){
		var rst=fun;
		rst=fun.bind(scope);;
		return rst;
	}

	Utils.measureText=function(txt,font){
		return RunDriver.measureText(txt,font);
	}

	Utils.updateOrder=function(array){
		if (!array || array.length < 2)return false;
		var i=1,j=0,len=array.length,key=NaN,c;
		while (i < len){
			j=i;
			c=array[j];
			key=array[j]._zOrder;
			while (--j >-1){
				if (array[j]._zOrder > key)array[j+1]=array[j];
				else break ;
			}
			array[j+1]=c;
			i++;
		}
		return true;
	}

	Utils.transPointList=function(points,x,y){
		var i=0,len=points.length;
		for (i=0;i < len;i+=2){
			points[i]+=x;
			points[i+1]+=y;
		}
	}

	Utils.parseInt=function(str,radix){
		(radix===void 0)&& (radix=0);
		var result=Browser.window.parseInt(str,radix);
		if (isNaN(result))return 0;
		return result;
	}

	Utils.getFileExtension=function(path){
		Utils._extReg.lastIndex=path.lastIndexOf(".");
		var result=Utils._extReg.exec(path);
		if (result && result.length > 1){
			return result[1].toLowerCase();
		}
		return null;
	}

	Utils.getTransformRelativeToWindow=function(coordinateSpace,x,y){
		var stage=Laya.stage;
		var globalTransform=laya.utils.Utils.getGlobalPosAndScale(coordinateSpace);
		var canvasMatrix=stage._canvasTransform.clone();
		var canvasLeft=canvasMatrix.tx;
		var canvasTop=canvasMatrix.ty;
		canvasMatrix.rotate(-Math.PI / 180 *Laya.stage.canvasDegree);
		canvasMatrix.scale(Laya.stage.clientScaleX,Laya.stage.clientScaleY);
		var perpendicular=(Laya.stage.canvasDegree % 180 !=0);
		var tx=NaN,ty=NaN;
		if (perpendicular){
			tx=y+globalTransform.y;
			ty=x+globalTransform.x;
			tx *=canvasMatrix.d;
			ty *=canvasMatrix.a;
			if (Laya.stage.canvasDegree==90){
				tx=canvasLeft-tx;
				ty+=canvasTop;
			}
			else {
				tx+=canvasLeft;
				ty=canvasTop-ty;
			}
		}
		else {
			tx=x+globalTransform.x;
			ty=y+globalTransform.y;
			tx *=canvasMatrix.a;
			ty *=canvasMatrix.d;
			tx+=canvasLeft;
			ty+=canvasTop;
		}
		ty+=Laya.stage['_safariOffsetY'];
		var domScaleX=NaN,domScaleY=NaN;
		if (perpendicular){
			domScaleX=canvasMatrix.d *globalTransform.height;
			domScaleY=canvasMatrix.a *globalTransform.width;
			}else {
			domScaleX=canvasMatrix.a *globalTransform.width;
			domScaleY=canvasMatrix.d *globalTransform.height;
		}
		return {x:tx,y:ty,scaleX:domScaleX,scaleY:domScaleY};
	}

	Utils.fitDOMElementInArea=function(dom,coordinateSpace,x,y,width,height){
		if (!dom._fitLayaAirInitialized){
			dom._fitLayaAirInitialized=true;
			dom.style.transformOrigin=dom.style.webKittransformOrigin="left top";
			dom.style.position="absolute"
		};
		var transform=Utils.getTransformRelativeToWindow(coordinateSpace,x,y);
		dom.style.transform=dom.style.webkitTransform="scale("+transform.scaleX+","+transform.scaleY+") rotate("+(Laya.stage.canvasDegree)+"deg)";
		dom.style.width=width+'px';
		dom.style.height=height+'px';
		dom.style.left=transform.x+'px';
		dom.style.top=transform.y+'px';
	}

	Utils.isOkTextureList=function(textureList){
		if (!textureList)return false;
		var i=0,len=textureList.length;
		var tTexture;
		for (i=0;i < len;i++){
			tTexture=textureList[i];
			if (!tTexture || !tTexture._getSource())return false;
		}
		return true;
	}

	Utils.isOKCmdList=function(cmds){
		if (!cmds)return false;
		var i=0,len=cmds.length;
		var cmd;
		var tex;
		for (i=0;i < len;i++){
			cmd=cmds[i];
		}
		return true;
	}

	Utils.getQueryString=function(name){
		if (Browser.onMiniGame)return null;
		var reg=new RegExp("(^|&)"+name+"=([^&]*)(&|$)");
		var r=window.location.search.substr(1).match(reg);
		if (r !=null)return unescape(r[2]);
		return null;
	}

	Utils._gid=1;
	Utils._pi=180 / Math.PI;
	Utils._pi2=Math.PI / 180;
	Utils._extReg=/\.(\w+)\??/g;
	Utils.parseXMLFromString=function(value){
		var rst;
		value=value.replace(/>\s+</g,'><');
		rst=(new DOMParser()).parseFromString(value,'text/xml');
		if (rst.firstChild.textContent.indexOf("This page contains the following errors")>-1){
			throw new Error(rst.firstChild.firstChild.textContent);
		}
		return rst;
	}

	return Utils;
})()


//class laya.utils.VectorGraphManager
var VectorGraphManager=(function(){
	function VectorGraphManager(){
		this.useDic={};
		this.shapeDic={};
		this.shapeLineDic={};
		this._id=0;
		this._checkKey=false;
		this._freeIdArray=[];
		if (Render.isWebGL){
			CacheManger.regCacheByFunction(Utils.bind(this.startDispose,this),Utils.bind(this.getCacheList,this));
		}
	}

	__class(VectorGraphManager,'laya.utils.VectorGraphManager');
	var __proto=VectorGraphManager.prototype;
	/**
	*得到个空闲的ID
	*@return
	*/
	__proto.getId=function(){
		return this._id++;
	}

	/**
	*添加一个图形到列表中
	*@param id
	*@param shape
	*/
	__proto.addShape=function(id,shape){
		this.shapeDic[id]=shape;
		if (!this.useDic[id]){
			this.useDic[id]=true;
		}
	}

	/**
	*添加一个线图形到列表中
	*@param id
	*@param Line
	*/
	__proto.addLine=function(id,Line){
		this.shapeLineDic[id]=Line;
		if (!this.shapeLineDic[id]){
			this.shapeLineDic[id]=true;
		}
	}

	/**
	*检测一个对象是否在使用中
	*@param id
	*/
	__proto.getShape=function(id){
		if (this._checkKey){
			if (this.useDic[id] !=null){
				this.useDic[id]=true;
			}
		}
	}

	/**
	*删除一个图形对象
	*@param id
	*/
	__proto.deleteShape=function(id){
		if (this.shapeDic[id]){
			this.shapeDic[id]=null;
			delete this.shapeDic[id];
		}
		if (this.shapeLineDic[id]){
			this.shapeLineDic[id]=null;
			delete this.shapeLineDic[id];
		}
		if (this.useDic[id] !=null){
			delete this.useDic[id];
		}
	}

	/**
	*得到缓存列表
	*@return
	*/
	__proto.getCacheList=function(){
		var str;
		var list=[];
		for (str in this.shapeDic){
			list.push(this.shapeDic[str]);
		}
		for (str in this.shapeLineDic){
			list.push(this.shapeLineDic[str]);
		}
		return list;
	}

	/**
	*开始清理状态，准备销毁
	*/
	__proto.startDispose=function(key){
		var str;
		for (str in this.useDic){
			this.useDic[str]=false;
		}
		this._checkKey=true;
	}

	/**
	*确认销毁
	*/
	__proto.endDispose=function(){
		if (this._checkKey){
			var str;
			for (str in this.useDic){
				if (!this.useDic[str]){
					this.deleteShape(str);
				}
			}
			this._checkKey=false;
		}
	}

	VectorGraphManager.getInstance=function(){
		return VectorGraphManager.instance=VectorGraphManager.instance|| new VectorGraphManager();
	}

	VectorGraphManager.instance=null;
	return VectorGraphManager;
})()


//class laya.utils.WeakObject
var WeakObject=(function(){
	function WeakObject(){
		/**@private */
		this._obj=null;
		this._obj=WeakObject.supportWeakMap ? new Browser.window.WeakMap():{};
		if (!WeakObject.supportWeakMap)WeakObject._maps.push(this);
	}

	__class(WeakObject,'laya.utils.WeakObject');
	var __proto=WeakObject.prototype;
	/**
	*设置缓存
	*@param key kye对象，可被回收
	*@param value object对象，可被回收
	*/
	__proto.set=function(key,value){
		if (key==null)return;
		if (WeakObject.supportWeakMap){
			var objKey=key;
			if ((typeof key=='string')|| (typeof key=='number')){
				objKey=WeakObject._keys[key];
				if (!objKey)objKey=WeakObject._keys[key]={k:key};
			}
			this._obj.set(objKey,value);
			}else {
			if ((typeof key=='string')|| (typeof key=='number')){
				this._obj[key]=value;
				}else {
				key.$_GID || (key.$_GID=Utils.getGID());
				this._obj[key.$_GID]=value;
			}
		}
	}

	/**
	*获取缓存
	*@param key kye对象，可被回收
	*/
	__proto.get=function(key){
		if (key==null)return null;
		if (WeakObject.supportWeakMap){
			var objKey=((typeof key=='string')|| (typeof key=='number'))? WeakObject._keys[key] :key;
			if (!objKey)return null;
			return this._obj.get(objKey);
			}else {
			if ((typeof key=='string')|| (typeof key=='number'))return this._obj[key];
			return this._obj[key.$_GID];
		}
	}

	//TODO:coverage
	__proto.del=function(key){
		if (key==null)return;
		if (WeakObject.supportWeakMap){
			var objKey=((typeof key=='string')|| (typeof key=='number'))? WeakObject._keys[key] :key;
			if (!objKey)return;
			this._obj.delete(objKey);
			}else {
			if ((typeof key=='string')|| (typeof key=='number'))delete this._obj[key];
			else delete this._obj[this._obj.$_GID];
		}
	}

	//TODO:coverage
	__proto.has=function(key){
		if (key==null)return false;
		if (WeakObject.supportWeakMap){
			var objKey=((typeof key=='string')|| (typeof key=='number'))? WeakObject._keys[key] :key;
			return this._obj.has(objKey);
			}else {
			if ((typeof key=='string')|| (typeof key=='number'))return this._obj[key] !=null;
			return this._obj[this._obj.$_GID] !=null;
		}
	}

	WeakObject.__init__=function(){
		WeakObject.supportWeakMap=Browser.window.WeakMap !=null;
		if (!WeakObject.supportWeakMap)Laya.systemTimer.loop(WeakObject.delInterval,null,WeakObject.clearCache);
	}

	WeakObject.clearCache=function(){
		for (var i=0,n=WeakObject._maps.length;i < n;i++){
			var obj=WeakObject._maps[i];
			obj._obj={};
		}
	}

	WeakObject.supportWeakMap=false;
	WeakObject.delInterval=10 *60 *1000;
	WeakObject._keys={};
	WeakObject._maps=[];
	__static(WeakObject,
	['I',function(){return this.I=new WeakObject();}
	]);
	return WeakObject;
})()


//class laya.utils.WordText
var WordText=(function(){
	function WordText(){
		//TODO:
		this.id=NaN;
		this.save=[];
		this.toUpperCase=null;
		this.changed=false;
		this._text=null;
		this.width=-1;
		//整个WordText的长度。-1表示没有计算还。
		this.pageChars=[];
		//把本对象的字符按照texture分组保存的文字信息。里面又是一个数组。具体含义见使用的地方。
		this.pageCharsStroke=[];
		//
		this.startID=0;
		//上面的是个数组，但是可能前面都是空的，加个起始位置
		this.startIDStroke=0;
		this.lastGCCnt=0;
	}

	__class(WordText,'laya.utils.WordText');
	var __proto=WordText.prototype;
	//如果文字gc了，需要检查缓存是否有效，这里记录上次检查对应的gc值。
	__proto.setText=function(txt){
		this.changed=true;
		this._text=txt;
		this.width=-1;
		this.pageChars=[];
	}

	//TODO:coverage
	__proto.toString=function(){
		return this._text;
	}

	//TODO:coverage
	__proto.charCodeAt=function(i){
		return this._text ? this._text.charCodeAt(i):NaN;
	}

	//TODO:coverage
	__proto.charAt=function(i){
		return this._text ? this._text.charAt(i):null;
	}

	__proto.cleanCache=function(){
		this.pageChars=[];
		this.startID=0;
	}

	__getset(0,__proto,'length',function(){
		return this._text ? this._text.length :0;
	});

	return WordText;
})()


//class laya.wx.mini.MiniAdpter
var MiniAdpter=(function(){
	function MiniAdpter(){}
	__class(MiniAdpter,'laya.wx.mini.MiniAdpter');
	MiniAdpter.getJson=function(data){
		return JSON.parse(data);
	}

	MiniAdpter.enable=function(){
		MiniAdpter.init(false,MiniAdpter.S_SON);
	}

	MiniAdpter.init=function(isPosMsg,isSon){
		(isPosMsg===void 0)&& (isPosMsg=false);
		(isSon===void 0)&& (isSon=false);
		if (MiniAdpter._inited)return;
		MiniAdpter._inited=true;
		MiniAdpter.window=window;
		if(MiniAdpter.window.navigator.userAgent.indexOf('MiniGame')<0)return;
		MiniAdpter.isZiYu=isSon;
		MiniAdpter.isPosMsgYu=isPosMsg;
		MiniAdpter.EnvConfig={};
		if(!MiniAdpter.isZiYu){
			MiniFileMgr.setNativeFileDir("/layaairGame");
			MiniFileMgr.existDir(MiniFileMgr.fileNativeDir,Handler.create(MiniAdpter,MiniAdpter.onMkdirCallBack));
		}
		MiniAdpter.systemInfo=wx.getSystemInfoSync();
		MiniAdpter.window.focus=function (){
		};
		Laya['_getUrlPath']=function (){
		};
		MiniAdpter.window.logtime=function (str){
		};
		MiniAdpter.window.alertTimeLog=function (str){
		};
		MiniAdpter.window.resetShareInfo=function (){
		};
		MiniAdpter.window.CanvasRenderingContext2D=function (){
		};
		MiniAdpter.window.CanvasRenderingContext2D.prototype=MiniAdpter.window.wx.createCanvas().getContext('2d').__proto__;
		MiniAdpter.window.document.body.appendChild=function (){
		};
		MiniAdpter.EnvConfig.pixelRatioInt=0;
		Browser["_pixelRatio"]=MiniAdpter.pixelRatio();
		MiniAdpter._preCreateElement=Browser.createElement;
		Browser["createElement"]=MiniAdpter.createElement;
		RunDriver.createShaderCondition=MiniAdpter.createShaderCondition;
		Utils['parseXMLFromString']=MiniAdpter.parseXMLFromString;
		Input['_createInputElement']=MiniInput['_createInputElement'];
		MiniAdpter.EnvConfig.load=Loader.prototype.load;
		Loader.prototype.load=MiniLoader.prototype.load;
		Loader.prototype._loadImage=MiniImage.prototype._loadImage;
		MiniLocalStorage.__init__();
		LocalStorage._baseClass=MiniLocalStorage;
		MiniAdpter.window.wx.onMessage(MiniAdpter._onMessage);
	}

	MiniAdpter._onMessage=function(data){
		if (data.type==="changeMatrix"){
			Laya.stage.transform.identity();
			Laya.stage._width=data.w;
			Laya.stage._height=data.h;
			Laya.stage._canvasTransform=new Matrix(data.a,data.b,data.c,data.d,data.tx,data.ty);
		}
		if(data['isLoad']=="opendatacontext"){
			if(data.url){
				MiniFileMgr.ziyuFileData[data.url]=data.atlasdata;
				MiniFileMgr.ziyuFileTextureData[data.imgReadyUrl]=data.imgNativeUrl;
			}
			}else if(data['isLoad']=="openJsondatacontext"){
			if(data.url){
				MiniFileMgr.ziyuFileData[data.url]=data.atlasdata;
			}
			}else if(data['isLoad']=="openJsondatacontextPic"){
			MiniFileMgr.ziyuFileTextureData[data.imgReadyUrl]=data.imgNativeUrl;
		}
	}

	MiniAdpter.getUrlEncode=function(url,type){
		if(type=="arraybuffer")
			return "";
		return "utf8";
	}

	MiniAdpter.downLoadFile=function(fileUrl,fileType,callBack,encoding){
		(fileType===void 0)&& (fileType="");
		(encoding===void 0)&& (encoding="utf8");
		var fileObj=MiniFileMgr.getFileInfo(fileUrl);
		if(!fileObj)
			MiniFileMgr.downLoadFile(fileUrl,fileType,callBack,encoding);
		else{
			callBack !=null && callBack.runWith([0]);
		}
	}

	MiniAdpter.remove=function(fileUrl,callBack){
		MiniFileMgr.deleteFile("",fileUrl,callBack,"",0);
	}

	MiniAdpter.removeAll=function(){
		MiniFileMgr.deleteAll();
	}

	MiniAdpter.hasNativeFile=function(fileUrl){
		return MiniFileMgr.isLocalNativeFile(fileUrl);
	}

	MiniAdpter.getFileInfo=function(fileUrl){
		return MiniFileMgr.getFileInfo(fileUrl);
	}

	MiniAdpter.getFileList=function(){
		return MiniFileMgr.filesListObj;
	}

	MiniAdpter.exitMiniProgram=function(){
		MiniAdpter.window["wx"].exitMiniProgram();
	}

	MiniAdpter.onMkdirCallBack=function(errorCode,data){
		if (!errorCode)
			MiniFileMgr.filesListObj=JSON.parse(data.data);
	}

	MiniAdpter.pixelRatio=function(){
		if (!MiniAdpter.EnvConfig.pixelRatioInt){
			try {
				MiniAdpter.EnvConfig.pixelRatioInt=MiniAdpter.systemInfo.pixelRatio;
				return MiniAdpter.systemInfo.pixelRatio;
			}catch (error){}
		}
		return MiniAdpter.EnvConfig.pixelRatioInt;
	}

	MiniAdpter.createElement=function(type){
		if (type=="canvas"){
			var _source;
			if (MiniAdpter.idx==1){
				if(MiniAdpter.isZiYu){
					_source=sharedCanvas;
					_source.style={};
					}else{
					_source=window.canvas;
				}
				}else {
				_source=window.wx.createCanvas();
			}
			MiniAdpter.idx++;
			return _source;
			}else if (type=="textarea" || type=="input"){
			return MiniAdpter.onCreateInput(type);
			}else if (type=="div"){
			var node=MiniAdpter._preCreateElement(type);
			node.contains=function (value){
				return null
			};
			node.removeChild=function (value){
			};
			return node;
			}else {
			return MiniAdpter._preCreateElement(type);
		}
	}

	MiniAdpter.onCreateInput=function(type){
		var node=MiniAdpter._preCreateElement(type);
		node.focus=MiniInput.wxinputFocus;
		node.blur=MiniInput.wxinputblur;
		node.style={};
		node.value=0;
		node.parentElement={};
		node.placeholder={};
		node.type={};
		node.setColor=function (value){
		};
		node.setType=function (value){
		};
		node.setFontFace=function (value){
		};
		node.addEventListener=function (value){
		};
		node.contains=function (value){
			return null
		};
		node.removeChild=function (value){
		};
		return node;
	}

	MiniAdpter.createShaderCondition=function(conditionScript){
		var _$this=this;
		var func=function (){
			var abc=conditionScript;
			return _$this[conditionScript.replace("this.","")];
		}
		return func;
	}

	MiniAdpter.sendAtlasToOpenDataContext=function(url){
		if(!laya.wx.mini.MiniAdpter.isZiYu){
			var atlasJson=Loader.getRes(URL.formatURL(url));
			if(atlasJson){
				var textureArr=(atlasJson.meta.image).split(",");
				if (atlasJson.meta && atlasJson.meta.image){
					var toloadPics=atlasJson.meta.image.split(",");
					var split=url.indexOf("/")>=0 ? "/" :"\\";
					var idx=url.lastIndexOf(split);
					var folderPath=idx >=0 ? url.substr(0,idx+1):"";
					for (var i=0,len=toloadPics.length;i < len;i++){
						toloadPics[i]=folderPath+toloadPics[i];
					}
					}else {
					toloadPics=[url.replace(".json",".png")];
				}
				for(i=0;i<toloadPics.length;i++){
					var tempAtlasPngUrl=toloadPics[i];
					MiniAdpter.postInfoToContext(url,tempAtlasPngUrl,atlasJson);
				}
				}else{
				throw "传递的url没有获取到对应的图集数据信息，请确保图集已经过！";
			}
		}
	}

	MiniAdpter.postInfoToContext=function(url,atlaspngUrl,atlasJson){
		var postData={"frames":atlasJson.frames,"meta":atlasJson.meta};
		var textureUrl=atlaspngUrl;
		var fileObj=MiniFileMgr.getFileInfo(URL.formatURL(atlaspngUrl));
		if(fileObj){
			var fileMd5Name=fileObj.md5;
			var fileNativeUrl=MiniFileMgr.getFileNativePath(fileMd5Name);
			}else{
			fileNativeUrl=textureUrl;
		}
		if(fileNativeUrl){
			wx.postMessage({url:url,atlasdata:postData,imgNativeUrl:fileNativeUrl,imgReadyUrl:textureUrl,isLoad:"opendatacontext"});
			}else{
			throw "获取图集的磁盘url路径不存在！";
		}
	}

	MiniAdpter.sendSinglePicToOpenDataContext=function(url){
		var tempTextureUrl=URL.formatURL(url);
		var fileObj=MiniFileMgr.getFileInfo(tempTextureUrl);
		if(fileObj){
			var fileMd5Name=fileObj.md5;
			var fileNativeUrl=MiniFileMgr.getFileNativePath(fileMd5Name);
			url=tempTextureUrl;
			}else{
			fileNativeUrl=url;
		}
		if(fileNativeUrl){
			wx.postMessage({url:url,imgNativeUrl:fileNativeUrl,imgReadyUrl:url,isLoad:"openJsondatacontextPic"});
			}else{
			throw "获取图集的磁盘url路径不存在！";
		}
	}

	MiniAdpter.sendJsonDataToDataContext=function(url){
		if(!laya.wx.mini.MiniAdpter.isZiYu){
			var atlasJson=Loader.getRes(url);
			if(atlasJson){
				wx.postMessage({url:url,atlasdata:atlasJson,isLoad:"openJsondatacontext"});
				}else{
				throw "传递的url没有获取到对应的图集数据信息，请确保图集已经过！";
			}
		}
	}

	MiniAdpter.EnvConfig=null;
	MiniAdpter.window=null;
	MiniAdpter._preCreateElement=null;
	MiniAdpter._inited=false;
	MiniAdpter.systemInfo=null;
	MiniAdpter.isZiYu=false;
	MiniAdpter.isPosMsgYu=false;
	MiniAdpter.autoCacheFile=true;
	MiniAdpter.minClearSize=(5 *1024 *1024);
	MiniAdpter.subNativeFiles=null;
	MiniAdpter.subNativeheads=[];
	MiniAdpter.subMaps=[];
	MiniAdpter.AutoCacheDownFile=false;
	MiniAdpter.S_SON=false;
	MiniAdpter.parseXMLFromString=function(value){
		var rst;
		var Parser;
		value=value.replace(/>\s+</g,'><');
		try {
			rst=(new window.Parser.DOMParser()).parseFromString(value,'text/xml');
			}catch (error){
			throw "需要引入xml解析库文件";
		}
		return rst;
	}

	MiniAdpter.idx=1;
	__static(MiniAdpter,
	['nativefiles',function(){return this.nativefiles=["layaNativeDir","wxlocal"];}
	]);
	return MiniAdpter;
})()


//class laya.wx.mini.MiniFileMgr
var MiniFileMgr=(function(){
	function MiniFileMgr(){}
	__class(MiniFileMgr,'laya.wx.mini.MiniFileMgr');
	MiniFileMgr.isLocalNativeFile=function(url){
		for(var i=0,sz=MiniAdpter.nativefiles.length;i<sz;i++){
			if(url.indexOf(MiniAdpter.nativefiles[i])!=-1)
				return true;
		}
		return false;
	}

	MiniFileMgr.getFileInfo=function(fileUrl){
		var fileNativePath=fileUrl;
		var fileObj=MiniFileMgr.filesListObj[fileNativePath];
		if (fileObj==null)
			return null;
		else
		return fileObj;
		return null;
	}

	MiniFileMgr.read=function(filePath,encoding,callBack,readyUrl,isSaveFile,fileType){
		(encoding===void 0)&& (encoding="ascill");
		(readyUrl===void 0)&& (readyUrl="");
		(isSaveFile===void 0)&& (isSaveFile=false);
		(fileType===void 0)&& (fileType="");
		var fileUrl;
		if(readyUrl!="" && (readyUrl.indexOf("http://")!=-1 || readyUrl.indexOf("https://")!=-1)){
			fileUrl=MiniFileMgr.getFileNativePath(filePath)
			}else{
			fileUrl=filePath;
		}
		fileUrl=URL.getAdptedFilePath(fileUrl);
		MiniFileMgr.fs.readFile({filePath:fileUrl,encoding:encoding,success:function (data){
				callBack !=null && callBack.runWith([0,data]);
				},fail:function (data){
				if (data && readyUrl !="")
					MiniFileMgr.downFiles(readyUrl,encoding,callBack,readyUrl,isSaveFile,fileType);
				else
				callBack !=null && callBack.runWith([1]);
		}});
	}

	MiniFileMgr.downFiles=function(fileUrl,encoding,callBack,readyUrl,isSaveFile,fileType,isAutoClear){
		(encoding===void 0)&& (encoding="ascii");
		(readyUrl===void 0)&& (readyUrl="");
		(isSaveFile===void 0)&& (isSaveFile=false);
		(fileType===void 0)&& (fileType="");
		(isAutoClear===void 0)&& (isAutoClear=true);
		var downloadTask=MiniFileMgr.wxdown({url:fileUrl,success:function (data){
				if (data.statusCode===200)
					MiniFileMgr.readFile(data.tempFilePath,encoding,callBack,readyUrl,isSaveFile,fileType,isAutoClear);
				else
				if(data.statusCode===403){
					callBack !=null && callBack.runWith([0,fileUrl]);
					}else{
					callBack !=null && callBack.runWith([1,data]);
				}
				},fail:function (data){
				callBack !=null && callBack.runWith([1,data]);
		}});
		downloadTask.onProgressUpdate(function(data){
			callBack !=null && callBack.runWith([2,data.progress]);
		});
	}

	MiniFileMgr.readFile=function(filePath,encoding,callBack,readyUrl,isSaveFile,fileType,isAutoClear){
		(encoding===void 0)&& (encoding="ascill");
		(readyUrl===void 0)&& (readyUrl="");
		(isSaveFile===void 0)&& (isSaveFile=false);
		(fileType===void 0)&& (fileType="");
		(isAutoClear===void 0)&& (isAutoClear=true);
		filePath=URL.getAdptedFilePath(filePath);
		MiniFileMgr.fs.readFile({filePath:filePath,encoding:encoding,success:function (data){
				if (filePath.indexOf("http://")!=-1 || filePath.indexOf("https://")!=-1){
					if(MiniAdpter.autoCacheFile || isSaveFile){
						MiniFileMgr.copyFile(filePath,readyUrl,callBack,encoding,isAutoClear);
					}
				}
				else
				callBack !=null && callBack.runWith([0,data]);
				},fail:function (data){
				if (data)
					callBack !=null && callBack.runWith([1,data]);
		}});
	}

	MiniFileMgr.downOtherFiles=function(fileUrl,callBack,readyUrl,isSaveFile,isAutoClear){
		(readyUrl===void 0)&& (readyUrl="");
		(isSaveFile===void 0)&& (isSaveFile=false);
		(isAutoClear===void 0)&& (isAutoClear=true);
		MiniFileMgr.wxdown({url:fileUrl,success:function (data){
				if (data.statusCode===200){
					if((MiniAdpter.autoCacheFile || isSaveFile)&& readyUrl.indexOf("wx.qlogo.cn")==-1 && readyUrl.indexOf(".php")==-1)
						MiniFileMgr.copyFile(data.tempFilePath,readyUrl,callBack,"",isAutoClear);
					else
					callBack !=null && callBack.runWith([0,data.tempFilePath]);
					}else{
					callBack !=null && callBack.runWith([1,data]);
				}
				},fail:function (data){
				callBack !=null && callBack.runWith([1,data]);
		}});
	}

	MiniFileMgr.downLoadFile=function(fileUrl,fileType,callBack,encoding){
		(fileType===void 0)&& (fileType="");
		(encoding===void 0)&& (encoding="ascii");
		if(window.navigator.userAgent.indexOf('MiniGame')<0){
			Laya.loader.load(fileUrl,callBack);
			}else{
			if(fileType=="image" || fileType=="sound")
				MiniFileMgr.downOtherFiles(fileUrl,callBack,fileUrl,true,false);
			else
			MiniFileMgr.downFiles(fileUrl,encoding,callBack,fileUrl,true,fileType,false);
		}
	}

	MiniFileMgr.copyFile=function(tempFilePath,readyUrl,callBack,encoding,isAutoClear){
		(encoding===void 0)&& (encoding="");
		(isAutoClear===void 0)&& (isAutoClear=true);
		var temp=tempFilePath.split("/");
		var tempFileName=temp[temp.length-1];
		var fileurlkey=readyUrl;
		var fileObj=MiniFileMgr.getFileInfo(readyUrl);
		var saveFilePath=MiniFileMgr.getFileNativePath(tempFileName);
		var totalSize=50 *1024 *1024;
		var chaSize=4 *1024 *1024;
		var fileUseSize=MiniFileMgr.getCacheUseSize();
		if (fileObj){
			if (fileObj.readyUrl !=readyUrl){
				MiniFileMgr.fs.getFileInfo({
					filePath:tempFilePath,
					success:function (data){
						if((isAutoClear && (fileUseSize+chaSize+data.size)>=totalSize)){
							if(data.size > MiniAdpter.minClearSize)
								MiniAdpter.minClearSize=data.size;
							MiniFileMgr.onClearCacheRes();
						}
						MiniFileMgr.deleteFile(tempFileName,readyUrl,callBack,encoding,data.size);
					},
					fail:function (data){
						callBack !=null && callBack.runWith([1,data]);
					}
				});
			}
			else
			callBack !=null && callBack.runWith([0]);
			}else{
			MiniFileMgr.fs.getFileInfo({
				filePath:tempFilePath,
				success:function (data){
					if((isAutoClear && (fileUseSize+chaSize+data.size)>=totalSize)){
						if(data.size > MiniAdpter.minClearSize)
							MiniAdpter.minClearSize=data.size;
						MiniFileMgr.onClearCacheRes();
					}
					MiniFileMgr.fs.copyFile({srcPath:tempFilePath,destPath:saveFilePath,success:function (data2){
							MiniFileMgr.onSaveFile(readyUrl,tempFileName,true,encoding,callBack,data.size);
							},fail:function (data){
							callBack !=null && callBack.runWith([1,data]);
					}});
				},
				fail:function (data){
					callBack !=null && callBack.runWith([1,data]);
				}
			});
		}
	}

	MiniFileMgr.onClearCacheRes=function(){
		var memSize=MiniAdpter.minClearSize;
		var tempFileListArr=[];
		for(var key in MiniFileMgr.filesListObj){
			tempFileListArr.push(MiniFileMgr.filesListObj[key]);
		}
		MiniFileMgr.sortOn(tempFileListArr,"times",16);
		var clearSize=0;
		for(var i=1,sz=tempFileListArr.length;i<sz;i++){
			var fileObj=tempFileListArr[i];
			if(clearSize >=memSize)
				break ;
			clearSize+=fileObj.size;
			MiniFileMgr.deleteFile("",fileObj.readyUrl);
		}
	}

	MiniFileMgr.sortOn=function(array,name,options){
		(options===void 0)&& (options=0);
		if (options==16)return array.sort(function(a,b){return a[name]-b[name];});
		if (options==(16 | 2))return array.sort(function(a,b){return b[name]-a[name];});
		return array.sort(function(a,b){return a[name]-b[name] });
	}

	MiniFileMgr.getFileNativePath=function(fileName){
		return laya.wx.mini.MiniFileMgr.fileNativeDir+"/"+fileName;
	}

	MiniFileMgr.deleteFile=function(tempFileName,readyUrl,callBack,encoding,fileSize){
		(readyUrl===void 0)&& (readyUrl="");
		(encoding===void 0)&& (encoding="");
		(fileSize===void 0)&& (fileSize=0);
		var fileObj=MiniFileMgr.getFileInfo(readyUrl);
		var deleteFileUrl=MiniFileMgr.getFileNativePath(fileObj.md5);
		MiniFileMgr.fs.unlink({filePath:deleteFileUrl,success:function (data){
				var isAdd=tempFileName !="" ? true :false;
				if(tempFileName !=""){
					var saveFilePath=MiniFileMgr.getFileNativePath(tempFileName);
					MiniFileMgr.fs.copyFile({srcPath:tempFileName,destPath:saveFilePath,success:function (data){
							MiniFileMgr.onSaveFile(readyUrl,tempFileName,isAdd,encoding,callBack,data.size);
							},fail:function (data){
							callBack !=null && callBack.runWith([1,data]);
					}});
					}else{
					MiniFileMgr.onSaveFile(readyUrl,tempFileName,isAdd,encoding,callBack,fileSize);
				}
				},fail:function (data){
		}});
	}

	MiniFileMgr.deleteAll=function(){
		var tempFileListArr=[];
		for(var key in MiniFileMgr.filesListObj){
			tempFileListArr.push(MiniFileMgr.filesListObj[key]);
		}
		for(var i=1,sz=tempFileListArr.length;i<sz;i++){
			var fileObj=tempFileListArr[i];
			MiniFileMgr.deleteFile("",fileObj.readyUrl);
		}
		if(laya.wx.mini.MiniFileMgr.filesListObj && laya.wx.mini.MiniFileMgr.filesListObj.fileUsedSize){
			laya.wx.mini.MiniFileMgr.filesListObj.fileUsedSize=0;
		}
		laya.wx.mini.MiniFileMgr.writeFilesList("",JSON.stringify({}),false);
	}

	MiniFileMgr.onSaveFile=function(readyUrl,md5Name,isAdd,encoding,callBack,fileSize){
		(isAdd===void 0)&& (isAdd=true);
		(encoding===void 0)&& (encoding="");
		(fileSize===void 0)&& (fileSize=0);
		var fileurlkey=readyUrl;
		if(MiniFileMgr.filesListObj['fileUsedSize']==null)
			MiniFileMgr.filesListObj['fileUsedSize']=0;
		if(isAdd){
			var fileNativeName=MiniFileMgr.getFileNativePath(md5Name);
			MiniFileMgr.filesListObj[fileurlkey]={md5:md5Name,readyUrl:readyUrl,size:fileSize,times:Browser.now(),encoding:encoding};
			MiniFileMgr.filesListObj['fileUsedSize']=parseInt(MiniFileMgr.filesListObj['fileUsedSize'])+fileSize;
			MiniFileMgr.writeFilesList(fileurlkey,JSON.stringify(MiniFileMgr.filesListObj),true);
			callBack !=null && callBack.runWith([0]);
			}else{
			if(MiniFileMgr.filesListObj[fileurlkey]){
				var deletefileSize=parseInt(MiniFileMgr.filesListObj[fileurlkey].size);
				MiniFileMgr.filesListObj['fileUsedSize']=parseInt(MiniFileMgr.filesListObj['fileUsedSize'])-deletefileSize;
				delete MiniFileMgr.filesListObj[fileurlkey];
				MiniFileMgr.writeFilesList(fileurlkey,JSON.stringify(MiniFileMgr.filesListObj),false);
				callBack !=null && callBack.runWith([0]);
			}
		}
	}

	MiniFileMgr.writeFilesList=function(fileurlkey,filesListStr,isAdd){
		var listFilesPath=MiniFileMgr.fileNativeDir+"/"+MiniFileMgr.fileListName;
		MiniFileMgr.fs.writeFile({filePath:listFilesPath,encoding:'utf8',data:filesListStr,success:function (data){
				},fail:function (data){
		}});
		if(!MiniAdpter.isZiYu &&MiniAdpter.isPosMsgYu){
			wx.postMessage({url:fileurlkey,data:MiniFileMgr.filesListObj[fileurlkey],isLoad:"filenative",isAdd:isAdd});
		}
	}

	MiniFileMgr.getCacheUseSize=function(){
		if(MiniFileMgr.filesListObj && MiniFileMgr.filesListObj['fileUsedSize'])
			return MiniFileMgr.filesListObj['fileUsedSize'];
		return 0;
	}

	MiniFileMgr.existDir=function(dirPath,callBack){
		MiniFileMgr.fs.mkdir({dirPath:dirPath,success:function (data){
				callBack !=null && callBack.runWith([0,{data:JSON.stringify({})}]);
				},fail:function (data){
				if (data.errMsg.indexOf("file already exists")!=-1)
					MiniFileMgr.readSync(MiniFileMgr.fileListName,"utf8",callBack);
				else
				callBack !=null && callBack.runWith([1,data]);
		}});
	}

	MiniFileMgr.readSync=function(filePath,encoding,callBack,readyUrl){
		(encoding===void 0)&& (encoding="ascill");
		(readyUrl===void 0)&& (readyUrl="");
		var fileUrl=MiniFileMgr.getFileNativePath(filePath);
		var filesListStr
		try{
			filesListStr=MiniFileMgr.fs.readFileSync(fileUrl,encoding);
			callBack !=null && callBack.runWith([0,{data:filesListStr}]);
		}
		catch(error){
			callBack !=null && callBack.runWith([1]);
		}
	}

	MiniFileMgr.setNativeFileDir=function(value){
		MiniFileMgr.fileNativeDir=wx.env.USER_DATA_PATH+value;
	}

	MiniFileMgr.filesListObj={};
	MiniFileMgr.fileNativeDir=null;
	MiniFileMgr.fileListName="layaairfiles.txt";
	MiniFileMgr.ziyuFileData={};
	MiniFileMgr.ziyuFileTextureData={};
	MiniFileMgr.loadPath="";
	MiniFileMgr.DESCENDING=2;
	MiniFileMgr.NUMERIC=16;
	__static(MiniFileMgr,
	['fs',function(){return this.fs=wx.getFileSystemManager();},'wxdown',function(){return this.wxdown=wx.downloadFile;}
	]);
	return MiniFileMgr;
})()


//class laya.wx.mini.MiniImage
var MiniImage=(function(){
	function MiniImage(){}
	__class(MiniImage,'laya.wx.mini.MiniImage');
	var __proto=MiniImage.prototype;
	/**@private **/
	__proto._loadImage=function(url){
		var thisLoader=this;
		if (MiniAdpter.isZiYu){
			MiniImage.onCreateImage(url,thisLoader,true);
			return;
		};
		var isTransformUrl=false;
		if (!MiniFileMgr.isLocalNativeFile(url)){
			isTransformUrl=true;
			url=URL.formatURL(url);
			}else{
			if (url.indexOf("http://")!=-1 || url.indexOf("https://")!=-1){
				if(MiniFileMgr.loadPath !=""){
					url=url.split(MiniFileMgr.loadPath)[1];
					}else{
					var tempStr=URL.rootPath !="" ? URL.rootPath :URL.basePath;
					var tempUrl=url;
					if(tempStr !="")
						url=url.split(tempStr)[1];
					if(!url){
						url=tempUrl;
					}
				}
			}
			if (MiniAdpter.subNativeFiles && MiniAdpter.subNativeheads.length==0){
				for (var key in MiniAdpter.subNativeFiles){
					var tempArr=MiniAdpter.subNativeFiles[key];
					MiniAdpter.subNativeheads=MiniAdpter.subNativeheads.concat(tempArr);
					for (var aa=0;aa < tempArr.length;aa++){
						MiniAdpter.subMaps[tempArr[aa]]=key+"/"+tempArr[aa];
					}
				}
			}
			if(MiniAdpter.subNativeFiles && url.indexOf("/")!=-1){
				var curfileHead=url.split("/")[0]+"/";
				if(curfileHead && MiniAdpter.subNativeheads.indexOf(curfileHead)!=-1){
					var newfileHead=MiniAdpter.subMaps[curfileHead];
					url=url.replace(curfileHead,newfileHead);
				}
			}
		}
		if (!MiniFileMgr.getFileInfo(url)){
			if (url.indexOf("http://")!=-1 || url.indexOf("https://")!=-1){
				if(MiniAdpter.isZiYu){
					MiniImage.onCreateImage(url,thisLoader,true);
					}else{
					MiniFileMgr.downOtherFiles(url,new Handler(MiniImage,MiniImage.onDownImgCallBack,[url,thisLoader]),url);
				}
			}
			else
			MiniImage.onCreateImage(url,thisLoader,true);
			}else {
			MiniImage.onCreateImage(url,thisLoader,!isTransformUrl);
		}
	}

	MiniImage.onDownImgCallBack=function(sourceUrl,thisLoader,errorCode,tempFilePath){
		(tempFilePath===void 0)&& (tempFilePath="");
		if (!errorCode)
			MiniImage.onCreateImage(sourceUrl,thisLoader,false,tempFilePath);
		else {
			thisLoader.onError(null);
		}
	}

	MiniImage.onCreateImage=function(sourceUrl,thisLoader,isLocal,tempFilePath){
		(isLocal===void 0)&& (isLocal=false);
		(tempFilePath===void 0)&& (tempFilePath="");
		var fileNativeUrl;
		if(MiniAdpter.autoCacheFile){
			if (!isLocal){
				if(tempFilePath !=""){
					fileNativeUrl=tempFilePath;
					}else{
					var fileObj=MiniFileMgr.getFileInfo(sourceUrl);
					var fileMd5Name=fileObj.md5;
					fileNativeUrl=MiniFileMgr.getFileNativePath(fileMd5Name);
				}
			}else
			if(MiniAdpter.isZiYu){
				var tempUrl=URL.formatURL(sourceUrl);
				if(MiniFileMgr.ziyuFileTextureData[tempUrl]){
					fileNativeUrl=MiniFileMgr.ziyuFileTextureData[tempUrl];
				}else
				fileNativeUrl=sourceUrl;
			}else
			fileNativeUrl=sourceUrl;
			}else{
			if(!isLocal)
				fileNativeUrl=tempFilePath;
			else
			fileNativeUrl=sourceUrl;
		}
		if (thisLoader._imgCache==null)
			thisLoader._imgCache={};
		var image;
		function clear (){
			var img=thisLoader._imgCache[fileNativeUrl];
			if (img){
				img.onload=null;
				img.onerror=null;
				delete thisLoader._imgCache[fileNativeUrl];
			}
		};
		var onerror=function (){
			clear();
			thisLoader.event("error","Load image failed");
		}
		if (thisLoader._type=="nativeimage"){
			var onload=function (){
				clear();
				thisLoader._url=URL.formatURL(thisLoader._url);
				thisLoader.onLoaded(image);
			};
			image=new Browser.window.Image();
			image.crossOrigin="";
			image.onload=onload;
			image.onerror=onerror;
			image.src=fileNativeUrl;
			thisLoader._imgCache[fileNativeUrl]=image;
			}else {
			var imageSource=new Browser.window.Image();
			onload=function (){
				thisLoader._url=URL.formatURL(thisLoader._url);
				image=HTMLImage.create(imageSource.width,imageSource.height);
				image.loadImageSource(imageSource,true);
				image._setUrl(fileNativeUrl);
				clear();
				thisLoader.onLoaded(image);
			};
			imageSource.crossOrigin="";
			imageSource.onload=onload;
			imageSource.onerror=onerror;
			imageSource.src=fileNativeUrl;
			thisLoader._imgCache[fileNativeUrl]=imageSource;
		}
	}

	return MiniImage;
})()


//class laya.wx.mini.MiniInput
var MiniInput=(function(){
	function MiniInput(){}
	__class(MiniInput,'laya.wx.mini.MiniInput');
	MiniInput._createInputElement=function(){
		Input['_initInput'](Input['area']=Browser.createElement("textarea"));
		Input['_initInput'](Input['input']=Browser.createElement("input"));
		Input['inputContainer']=Browser.createElement("div");
		Input['inputContainer'].style.position="absolute";
		Input['inputContainer'].style.zIndex=1E5;
		Browser.container.appendChild(Input['inputContainer']);
		Input['inputContainer'].setPos=function (x,y){Input['inputContainer'].style.left=x+'px';Input['inputContainer'].style.top=y+'px';};
		Laya.stage.on("resize",null,MiniInput._onStageResize);
		wx.onWindowResize && wx.onWindowResize(function(res){
			window.dispatchEvent && window.dispatchEvent("resize");
		});
		SoundManager._soundClass=MiniSound;
		SoundManager._musicClass=MiniSound;
		var model=MiniAdpter.systemInfo.model;
		var system=MiniAdpter.systemInfo.system;
		if(model.indexOf("iPhone")!=-1){
			Browser.onIPhone=true;
			Browser.onIOS=true;
			Browser.onIPad=true;
			Browser.onAndroid=false;
		}
		if(system.indexOf("Android")!=-1 || system.indexOf("Adr")!=-1){
			Browser.onAndroid=true;
			Browser.onIPhone=false;
			Browser.onIOS=false;
			Browser.onIPad=false;
		}
	}

	MiniInput._onStageResize=function(){
		var ts=Laya.stage._canvasTransform.identity();
		ts.scale((Browser.width / Render.canvas.width / Browser.pixelRatio),Browser.height / Render.canvas.height / Browser.pixelRatio);
	}

	MiniInput.wxinputFocus=function(e){
		var _inputTarget=Input['inputElement'].target;
		if (_inputTarget && !_inputTarget.editable){
			return;
		}
		MiniAdpter.window.wx.offKeyboardConfirm();
		MiniAdpter.window.wx.offKeyboardInput();
		MiniAdpter.window.wx.showKeyboard({defaultValue:_inputTarget.text,maxLength:_inputTarget.maxChars,multiple:_inputTarget.multiline,confirmHold:true,confirmType:'done',success:function (res){
				},fail:function (res){
		}});
		MiniAdpter.window.wx.onKeyboardConfirm(function(res){
			var str=res ? res.value :"";
			_inputTarget.text=str;
			_inputTarget.event("input");
			laya.wx.mini.MiniInput.inputEnter();
		})
		MiniAdpter.window.wx.onKeyboardInput(function(res){
			var str=res ? res.value :"";
			if (!_inputTarget.multiline){
				if (str.indexOf("\n")!=-1){
					laya.wx.mini.MiniInput.inputEnter();
					return;
				}
			}
			_inputTarget.text=str;
			_inputTarget.event("input");
		});
	}

	MiniInput.inputEnter=function(){
		Input['inputElement'].target.focus=false;
	}

	MiniInput.wxinputblur=function(){
		MiniInput.hideKeyboard();
	}

	MiniInput.hideKeyboard=function(){
		MiniAdpter.window.wx.offKeyboardConfirm();
		MiniAdpter.window.wx.offKeyboardInput();
		MiniAdpter.window.wx.hideKeyboard({success:function (res){
				console.log('隐藏键盘')
				},fail:function (res){
				console.log("隐藏键盘出错:"+(res ? res.errMsg :""));
		}});
	}

	return MiniInput;
})()


//class laya.wx.mini.MiniLocalStorage
var MiniLocalStorage=(function(){
	function MiniLocalStorage(){}
	__class(MiniLocalStorage,'laya.wx.mini.MiniLocalStorage');
	MiniLocalStorage.__init__=function(){
		MiniLocalStorage.items=MiniLocalStorage;
	}

	MiniLocalStorage.setItem=function(key,value){
		try{
			wx.setStorageSync(key,value);
		}
		catch(error){
			wx.setStorage({
				key:key,
				data:value
			});
		}
	}

	MiniLocalStorage.getItem=function(key){
		return wx.getStorageSync(key);
	}

	MiniLocalStorage.setJSON=function(key,value){
		MiniLocalStorage.setItem(key,value);
	}

	MiniLocalStorage.getJSON=function(key){
		return MiniLocalStorage.getItem(key);
	}

	MiniLocalStorage.removeItem=function(key){
		wx.removeStorageSync(key);
	}

	MiniLocalStorage.clear=function(){
		wx.clearStorageSync();
	}

	MiniLocalStorage.getStorageInfoSync=function(){
		try {
			var res=wx.getStorageInfoSync()
			console.log(res.keys)
			console.log(res.currentSize)
			console.log(res.limitSize)
			return res;
		}catch (e){}
		return null;
	}

	MiniLocalStorage.support=true;
	MiniLocalStorage.items=null;
	return MiniLocalStorage;
})()


//class UIConfig
var UIConfig=(function(){
	function UIConfig(){}
	__class(UIConfig,'UIConfig');
	UIConfig.touchScrollEnable=true;
	UIConfig.mouseWheelEnable=true;
	UIConfig.showButtons=true;
	UIConfig.popupBgColor="#000000";
	UIConfig.popupBgAlpha=0.5;
	UIConfig.closeDialogOnSide=true;
	return UIConfig;
})()


//class laya.resource.Resource extends laya.events.EventDispatcher
var Resource=(function(_super){
	function Resource(){
		/**@private */
		//this._id=0;
		/**@private */
		//this._url=null;
		/**@private */
		//this._group=null;
		/**@private */
		//this._cpuMemory=0;
		/**@private */
		//this._gpuMemory=0;
		/**@private */
		//this._released=false;
		/**@private */
		//this._destroyed=false;
		/**@private */
		//this._referenceCount=0;
		/**@private */
		//this._resourceManager=null;
		/**是否加锁，如果true为不能使用自动释放机制。*/
		//this.lock=false;
		/**名称。 */
		//this.name=null;
		Resource.__super.call(this);
		this._id=++Resource._uniqueIDCounter;
		this._destroyed=false;
		this._referenceCount=0;
		Resource._idResourcesMap[this.id]=this;
		this._released=true;
		this.lock=false;
		this._gpuMemory=0;
		(ResourceManager.currentResourceManager)&& (ResourceManager.currentResourceManager.addResource(this));
	}

	__class(Resource,'laya.resource.Resource',_super);
	var __proto=Resource.prototype;
	Laya.imps(__proto,{"laya.resource.ICreateResource":true,"laya.resource.IDestroy":true})
	//TODO:coverage
	__proto._setCPUMemory=function(value){
		var offsetValue=value-this._cpuMemory;
		this._cpuMemory=value;
	}

	/**
	*@private
	*/
	__proto._setGPUMemory=function(value){
		var offsetValue=value-this._gpuMemory;
		this._gpuMemory=value;
		this.resourceManager && this.resourceManager.addSize(offsetValue);
	}

	/**
	*@private
	*/
	__proto._setUrl=function(url){
		if (this._url!==url){
			var resList;
			if (this._url){
				resList=Resource._urlResourcesMap[this._url];
				resList.splice(resList.indexOf(this),1);
				(resList.length===0)&& (delete Resource._urlResourcesMap[this._url]);
			}
			if (url){
				resList=Resource._urlResourcesMap[url];
				(resList)|| (Resource._urlResourcesMap[url]=resList=[]);
				resList.push(this);
			}
			this._url=url;
		}
	}

	//TODO:coverage
	__proto._getGroup=function(){
		return this._group;
	}

	//TODO:coverage
	__proto._setGroup=function(value){
		if (this._group!==value){
			var groupList;
			if (this._group){
				groupList=Resource._groupResourcesMap[this._group];
				groupList.splice(groupList.indexOf(this),1);
				(groupList.length===0)&& (delete Resource._groupResourcesMap[this._group]);
			}
			if (value){
				groupList=Resource._groupResourcesMap[value];
				(groupList)|| (Resource._groupResourcesMap[value]=groupList=[]);
				groupList.push(this);
			}
			this._group=value;
		}
	}

	/**
	*@private
	*/
	__proto._addReference=function(count){
		(count===void 0)&& (count=1);
		this._referenceCount+=count;
	}

	/**
	*@private
	*/
	__proto._removeReference=function(count){
		(count===void 0)&& (count=1);
		this._referenceCount-=count;
	}

	//TODO:coverage
	__proto._clearReference=function(){
		this._referenceCount=0;
	}

	//TODO:coverage
	__proto._completeLoad=function(){
		this._released=false;
	}

	/**
	*@private
	*/
	__proto._recoverResource=function(){}
	/**
	*@private
	*/
	__proto._disposeResource=function(){}
	/**
	*@private
	*/
	__proto._activeResource=function(){
		this._released=false;
	}

	//TODO:coverage
	__proto._onAsynLoaded=function(data,propertyParams){
		throw new Error("Resource: must override this function!");
	}

	/**
	*释放资源。
	*@param force 是否强制释放。
	*@return 是否成功释放。
	*/
	__proto.releaseResource=function(force){
		(force===void 0)&& (force=false);
		if (!force && this.lock)
			return false;
		if (!this._released || force){
			this._disposeResource();
			this._released=true;
			return true;
		}
		else {
			return false;
		}
	}

	/**
	*销毁资源,销毁后资源不能恢复。
	*/
	__proto.destroy=function(){
		if (this._destroyed)
			return;
		if (this._resourceManager!==null)
			this._resourceManager.removeResource(this);
		this._destroyed=true;
		this.lock=false;
		this.releaseResource();
		delete Resource._idResourcesMap[this.id];
		var resList;
		if (this._url){
			resList=Resource._urlResourcesMap[this._url];
			if (resList){
				resList.splice(resList.indexOf(this),1);
				(resList.length===0)&& (delete Resource._urlResourcesMap[this.url]);
			};
			var resou=Loader.getRes(this._url);
			(resou==this)&& (delete Loader.loadedMap[this._url]);
			RunDriver.cancelLoadByUrl(this._url);
		}
		if (this._group){
			resList=Resource._groupResourcesMap[this._group];
			resList.splice(resList.indexOf(this),1);
			(resList.length===0)&& (delete Resource._groupResourcesMap[this.url]);
		}
	}

	/**
	*获取唯一标识ID,通常用于识别。
	*/
	__getset(0,__proto,'id',function(){
		return this._id;
	});

	/**
	*是否已释放。
	*/
	__getset(0,__proto,'released',function(){
		return this._released;
	});

	/**
	*获取资源的URL地址。
	*@return URL地址。
	*/
	__getset(0,__proto,'url',function(){
		return this._url;
	});

	/**
	*显存大小。
	*/
	__getset(0,__proto,'gpuMemory',function(){
		return this._gpuMemory;
	});

	/**
	*设置资源组名。
	*/
	/**
	*获取资源组名。
	*/
	__getset(0,__proto,'group',function(){
		return this._getGroup();
		},function(value){
		this._setGroup(value);
	});

	/**
	*是否已处理。
	*/
	__getset(0,__proto,'destroyed',function(){
		return this._destroyed;
	});

	/**
	*资源管理员。
	*/
	__getset(0,__proto,'resourceManager',function(){
		return this._resourceManager;
	});

	/**
	*内存大小。
	*/
	__getset(0,__proto,'cpuMemory',function(){
		return this._cpuMemory;
	});

	/**
	*获取资源的引用计数。
	*/
	__getset(0,__proto,'referenceCount',function(){
		return this._referenceCount;
	});

	Resource.getResourceByID=function(id){
		return Resource._idResourcesMap[id];
	}

	Resource.getResourceByURL=function(url,index){
		(index===void 0)&& (index=0);
		return Resource._urlResourcesMap[url][index];
	}

	Resource.destroyUnusedResources=function(group){
		var res;
		if (group){
			var resouList=Resource._groupResourcesMap[group];
			if (resouList){
				var tempResouList=resouList.slice();
				for (var i=0,n=tempResouList.length;i < n;i++){
					res=tempResouList[i];
					if (!res.lock && res._referenceCount===0)
						res.destroy();
				}
			}
		}
		else {
			for (var k in Resource._idResourcesMap){
				res=Resource._idResourcesMap[k];
				if (!res.lock && res._referenceCount===0)
					res.destroy();
			}
		}
	}

	Resource._uniqueIDCounter=0;
	Resource._idResourcesMap={};
	Resource._urlResourcesMap={};
	Resource._groupResourcesMap={};
	return Resource;
})(EventDispatcher)


//class laya.display.Node extends laya.events.EventDispatcher
var Node=(function(_super){
	function Node(){
		/**@private */
		this._bits=0;
		/**@private 父节点对象*/
		this._parent=null;
		/**节点名称。*/
		this.name="";
		/**[只读]是否已经销毁。对象销毁后不能再使用。*/
		this.destroyed=false;
		/**@private */
		this._conchData=null;
		/**@private */
		this._components=null;
		/**@private */
		this._scene=null;
		Node.__super.call(this);
		this._children=Node.ARRAY_EMPTY;
		this.createGLBuffer();
	}

	__class(Node,'laya.display.Node',_super);
	var __proto=Node.prototype;
	/**@private */
	__proto.createGLBuffer=function(){}
	/**@private */
	__proto._setBit=function(type,value){
		if (type===0x10){
			var preValue=this._getBit(type);
			if (preValue !=value)this._updateDisplayedInstage();
		}
		if (value)this._bits |=type;
		else this._bits &=~type;
	}

	/**@private */
	__proto._getBit=function(type){
		return (this._bits & type)!=0;
	}

	/**@private */
	__proto._setUpNoticeChain=function(){
		if (this._getBit(0x10))this._setBitUp(0x10);
	}

	/**@private */
	__proto._setBitUp=function(type){
		var ele=this;
		ele._setBit(type,true);
		ele=ele._parent;
		while (ele){
			if (ele._getBit(type))return;
			ele._setBit(type,true);
			ele=ele._parent;
		}
	}

	/**
	*<p>增加事件侦听器，以使侦听器能够接收事件通知。</p>
	*<p>如果侦听鼠标事件，则会自动设置自己和父亲节点的属性 mouseEnabled 的值为 true(如果父节点mouseEnabled=false，则停止设置父节点mouseEnabled属性)。</p>
	*@param type 事件的类型。
	*@param caller 事件侦听函数的执行域。
	*@param listener 事件侦听函数。
	*@param args （可选）事件侦听函数的回调参数。
	*@return 此 EventDispatcher 对象。
	*/
	__proto.on=function(type,caller,listener,args){
		if (type==="display" || type==="undisplay"){
			if (!this._getBit(0x10))this._setBitUp(0x10);
		}
		return this._createListener(type,caller,listener,args,false);
	}

	/**
	*<p>增加事件侦听器，以使侦听器能够接收事件通知，此侦听事件响应一次后则自动移除侦听。</p>
	*<p>如果侦听鼠标事件，则会自动设置自己和父亲节点的属性 mouseEnabled 的值为 true(如果父节点mouseEnabled=false，则停止设置父节点mouseEnabled属性)。</p>
	*@param type 事件的类型。
	*@param caller 事件侦听函数的执行域。
	*@param listener 事件侦听函数。
	*@param args （可选）事件侦听函数的回调参数。
	*@return 此 EventDispatcher 对象。
	*/
	__proto.once=function(type,caller,listener,args){
		if (type==="display" || type==="undisplay"){
			if (!this._getBit(0x10))this._setBitUp(0x10);
		}
		return this._createListener(type,caller,listener,args,true);
	}

	/**
	*<p>销毁此对象。destroy对象默认会把自己从父节点移除，并且清理自身引用关系，等待js自动垃圾回收机制回收。destroy后不能再使用。</p>
	*<p>destroy时会移除自身的事情监听，自身的timer监听，移除子对象及从父节点移除自己。</p>
	*@param destroyChild （可选）是否同时销毁子节点，若值为true,则销毁子节点，否则不销毁子节点。
	*/
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		this.destroyed=true;
		this._destroyAllComponent();
		this._parent && this._parent.removeChild(this);
		if (this._children){
			if (destroyChild)this.destroyChildren();
			else this.removeChildren();
		}
		this.onDestroy();
		this._children=null;
		this.offAll();
	}

	/**
	*销毁时执行
	*此方法为虚方法，使用时重写覆盖即可
	*/
	__proto.onDestroy=function(){}
	/**
	*销毁所有子对象，不销毁自己本身。
	*/
	__proto.destroyChildren=function(){
		if (this._children){
			for (var i=0,n=this._children.length;i < n;i++){
				this._children[0].destroy(true);
			}
		}
	}

	/**
	*添加子节点。
	*@param node 节点对象
	*@return 返回添加的节点
	*/
	__proto.addChild=function(node){
		if (!node || this.destroyed || node===this)return node;
		if ((node)._zOrder)this._setBit(0x20,true);
		if (node._parent===this){
			var index=this.getChildIndex(node);
			if (index!==this._children.length-1){
				this._children.splice(index,1);
				this._children.push(node);
				this._childChanged();
			}
			}else {
			node._parent && node._parent.removeChild(node);
			this._children===Node.ARRAY_EMPTY && (this._children=[]);
			this._children.push(node);
			node._setParent(this);
			this._childChanged();
		}
		return node;
	}

	/**
	*批量增加子节点
	*@param ...args 无数子节点。
	*/
	__proto.addChildren=function(__args){
		var args=arguments;
		var i=0,n=args.length;
		while (i < n){
			this.addChild(args[i++]);
		}
	}

	/**
	*添加子节点到指定的索引位置。
	*@param node 节点对象。
	*@param index 索引位置。
	*@return 返回添加的节点。
	*/
	__proto.addChildAt=function(node,index){
		if (!node || this.destroyed || node===this)return node;
		if ((node)._zOrder)this._setBit(0x20,true);
		if (index >=0 && index <=this._children.length){
			if (node._parent===this){
				var oldIndex=this.getChildIndex(node);
				this._children.splice(oldIndex,1);
				this._children.splice(index,0,node);
				this._childChanged();
				}else {
				node._parent && node._parent.removeChild(node);
				this._children===Node.ARRAY_EMPTY && (this._children=[]);
				this._children.splice(index,0,node);
				node._setParent(this);
			}
			return node;
			}else {
			throw new Error("appendChildAt:The index is out of bounds");
		}
	}

	/**
	*根据子节点对象，获取子节点的索引位置。
	*@param node 子节点。
	*@return 子节点所在的索引位置。
	*/
	__proto.getChildIndex=function(node){
		return this._children.indexOf(node);
	}

	/**
	*根据子节点的名字，获取子节点对象。
	*@param name 子节点的名字。
	*@return 节点对象。
	*/
	__proto.getChildByName=function(name){
		var nodes=this._children;
		if (nodes){
			for (var i=0,n=nodes.length;i < n;i++){
				var node=nodes[i];
				if (node.name===name)return node;
			}
		}
		return null;
	}

	/**
	*根据子节点的索引位置，获取子节点对象。
	*@param index 索引位置
	*@return 子节点
	*/
	__proto.getChildAt=function(index){
		return this._children[index] || null;
	}

	/**
	*设置子节点的索引位置。
	*@param node 子节点。
	*@param index 新的索引。
	*@return 返回子节点本身。
	*/
	__proto.setChildIndex=function(node,index){
		var childs=this._children;
		if (index < 0 || index >=childs.length){
			throw new Error("setChildIndex:The index is out of bounds.");
		};
		var oldIndex=this.getChildIndex(node);
		if (oldIndex < 0)throw new Error("setChildIndex:node is must child of this object.");
		childs.splice(oldIndex,1);
		childs.splice(index,0,node);
		this._childChanged();
		return node;
	}

	/**
	*子节点发生改变。
	*@private
	*@param child 子节点。
	*/
	__proto._childChanged=function(child){}
	/**
	*删除子节点。
	*@param node 子节点
	*@return 被删除的节点
	*/
	__proto.removeChild=function(node){
		if (!this._children)return node;
		var index=this._children.indexOf(node);
		return this.removeChildAt(index);
	}

	/**
	*从父容器删除自己，如已经被删除不会抛出异常。
	*@return 当前节点（ Node ）对象。
	*/
	__proto.removeSelf=function(){
		this._parent && this._parent.removeChild(this);
		return this;
	}

	/**
	*根据子节点名字删除对应的子节点对象，如果找不到不会抛出异常。
	*@param name 对象名字。
	*@return 查找到的节点（ Node ）对象。
	*/
	__proto.removeChildByName=function(name){
		var node=this.getChildByName(name);
		node && this.removeChild(node);
		return node;
	}

	/**
	*根据子节点索引位置，删除对应的子节点对象。
	*@param index 节点索引位置。
	*@return 被删除的节点。
	*/
	__proto.removeChildAt=function(index){
		var node=this.getChildAt(index);
		if (node){
			this._children.splice(index,1);
			node._setParent(null);
		}
		return node;
	}

	/**
	*删除指定索引区间的所有子对象。
	*@param beginIndex 开始索引。
	*@param endIndex 结束索引。
	*@return 当前节点对象。
	*/
	__proto.removeChildren=function(beginIndex,endIndex){
		(beginIndex===void 0)&& (beginIndex=0);
		(endIndex===void 0)&& (endIndex=0x7fffffff);
		if (this._children && this._children.length > 0){
			var childs=this._children;
			if (beginIndex===0 && endIndex >=childs.length-1){
				var arr=childs;
				this._children=Node.ARRAY_EMPTY;
				}else {
				arr=childs.splice(beginIndex,endIndex-beginIndex);
			}
			for (var i=0,n=arr.length;i < n;i++){
				arr[i]._setParent(null);
			}
		}
		return this;
	}

	/**
	*替换子节点。
	*@internal 将传入的新节点对象替换到已有子节点索引位置处。
	*@param newNode 新节点。
	*@param oldNode 老节点。
	*@return 返回新节点。
	*/
	__proto.replaceChild=function(newNode,oldNode){
		var index=this._children.indexOf(oldNode);
		if (index >-1){
			this._children.splice(index,1,newNode);
			oldNode._setParent(null);
			newNode._setParent(this);
			return newNode;
		}
		return null;
	}

	/**@private */
	__proto._setParent=function(value){
		if (this._parent!==value){
			if (value){
				this._parent=value;
				this._onAdded();
				this.event("added");
				if (this._getBit(0x10)){
					this._setUpNoticeChain();
					value.displayedInStage && this._displayChild(this,true);
				}
				value._childChanged(this);
				}else {
				this._onRemoved();
				this.event("removed");
				this._parent._childChanged();
				if (this._getBit(0x10))this._displayChild(this,false);
				this._parent=value;
			}
		}
	}

	/**@private */
	__proto._updateDisplayedInstage=function(){
		var ele;
		ele=this;
		var stage=Laya.stage;
		var displayedInStage=false;
		while (ele){
			if (ele._getBit(0x10)){
				displayedInStage=ele._getBit(0x80);
				break ;
			}
			if (ele===stage || ele._getBit(0x80)){
				displayedInStage=true;
				break ;
			}
			ele=ele._parent;
		}
		this._setBit(0x80,displayedInStage);
	}

	/**@private */
	__proto._setDisplay=function(value){
		if (this._getBit(0x80)!==value){
			this._setBit(0x80,value);
			if (value)this.event("display");
			else this.event("undisplay");
		}
	}

	/**
	*设置指定节点对象是否可见(是否在渲染列表中)。
	*@private
	*@param node 节点。
	*@param display 是否可见。
	*/
	__proto._displayChild=function(node,display){
		var childs=node._children;
		if (childs){
			for (var i=0,n=childs.length;i < n;i++){
				var child=childs[i];
				if (!child._getBit(0x10))continue ;
				if (child._children.length > 0){
					this._displayChild(child,display);
					}else {
					child._setDisplay(display);
				}
			}
		}
		node._setDisplay(display);
	}

	/**
	*当前容器是否包含指定的 <code>Node</code> 节点对象 。
	*@param node 指定的 <code>Node</code> 节点对象 。
	*@return 一个布尔值表示是否包含指定的 <code>Node</code> 节点对象 。
	*/
	__proto.contains=function(node){
		if (node===this)return true;
		while (node){
			if (node._parent===this)return true;
			node=node._parent;
		}
		return false;
	}

	/**
	*定时重复执行某函数。功能同Laya.timer.timerLoop()。
	*@param delay 间隔时间(单位毫秒)。
	*@param caller 执行域(this)。
	*@param method 结束时的回调方法。
	*@param args （可选）回调参数。
	*@param coverBefore （可选）是否覆盖之前的延迟执行，默认为true。
	*@param jumpFrame 时钟是否跳帧。基于时间的循环回调，单位时间间隔内，如能执行多次回调，出于性能考虑，引擎默认只执行一次，设置jumpFrame=true后，则回调会连续执行多次
	*/
	__proto.timerLoop=function(delay,caller,method,args,coverBefore,jumpFrame){
		(coverBefore===void 0)&& (coverBefore=true);
		(jumpFrame===void 0)&& (jumpFrame=false);
		var timer=this.scene ? this.scene.timer :Laya.timer;
		timer.loop(delay,caller,method,args,coverBefore,jumpFrame);
	}

	/**
	*定时执行某函数一次。功能同Laya.timer.timerOnce()。
	*@param delay 延迟时间(单位毫秒)。
	*@param caller 执行域(this)。
	*@param method 结束时的回调方法。
	*@param args （可选）回调参数。
	*@param coverBefore （可选）是否覆盖之前的延迟执行，默认为true。
	*/
	__proto.timerOnce=function(delay,caller,method,args,coverBefore){
		(coverBefore===void 0)&& (coverBefore=true);
		var timer=this.scene ? this.scene.timer :Laya.timer;
		timer._create(false,false,delay,caller,method,args,coverBefore);
	}

	/**
	*定时重复执行某函数(基于帧率)。功能同Laya.timer.frameLoop()。
	*@param delay 间隔几帧(单位为帧)。
	*@param caller 执行域(this)。
	*@param method 结束时的回调方法。
	*@param args （可选）回调参数。
	*@param coverBefore （可选）是否覆盖之前的延迟执行，默认为true。
	*/
	__proto.frameLoop=function(delay,caller,method,args,coverBefore){
		(coverBefore===void 0)&& (coverBefore=true);
		var timer=this.scene ? this.scene.timer :Laya.timer;
		timer._create(true,true,delay,caller,method,args,coverBefore);
	}

	/**
	*定时执行一次某函数(基于帧率)。功能同Laya.timer.frameOnce()。
	*@param delay 延迟几帧(单位为帧)。
	*@param caller 执行域(this)
	*@param method 结束时的回调方法
	*@param args （可选）回调参数
	*@param coverBefore （可选）是否覆盖之前的延迟执行，默认为true
	*/
	__proto.frameOnce=function(delay,caller,method,args,coverBefore){
		(coverBefore===void 0)&& (coverBefore=true);
		var timer=this.scene ? this.scene.timer :Laya.timer;
		timer._create(true,false,delay,caller,method,args,coverBefore);
	}

	/**
	*清理定时器。功能同Laya.timer.clearTimer()。
	*@param caller 执行域(this)。
	*@param method 结束时的回调方法。
	*/
	__proto.clearTimer=function(caller,method){
		var timer=this.scene ? this.scene.timer :Laya.timer;
		timer.clear(caller,method);
	}

	/**
	*<p>延迟运行指定的函数。</p>
	*<p>在控件被显示在屏幕之前调用，一般用于延迟计算数据。</p>
	*@param method 要执行的函数的名称。例如，functionName。
	*@param args 传递给 <code>method</code> 函数的可选参数列表。
	*
	*@see #runCallLater()
	*/
	__proto.callLater=function(method,args){
		var timer=this.scene ? this.scene.timer :Laya.timer;
		timer.callLater(this,method,args);
	}

	/**
	*<p>如果有需要延迟调用的函数（通过 <code>callLater</code> 函数设置），则立即执行延迟调用函数。</p>
	*@param method 要执行的函数名称。例如，functionName。
	*@see #callLater()
	*/
	__proto.runCallLater=function(method){
		var timer=this.scene ? this.scene.timer :Laya.timer;
		timer.runCallLater(this,method);
	}

	/**
	*@private
	*/
	__proto._onActive=function(){}
	/**
	*@private
	*/
	__proto._onInActive=function(){}
	/**
	*@private
	*/
	__proto._onActiveInScene=function(){}
	/**
	*@private
	*/
	__proto._onInActiveInScene=function(){}
	/**
	*@private
	*/
	__proto._parse=function(data){}
	/**
	*@private
	*/
	__proto._setBelongScene=function(scene){
		if (!this._scene){
			this._scene=scene;
			if (this._components){
				for (var i=0,n=this._components.length;i < n;i++)
				this._components[i]._setActiveInScene(true);
			}
			this._onActiveInScene();
			for (i=0,n=this._children.length;i < n;i++)
			this._children[i]._setBelongScene(scene);
		}
	}

	/**
	*@private
	*/
	__proto._setUnBelongScene=function(){
		if (this._scene!==this){
			this._onInActiveInScene();
			if (this._components){
				for (var i=0,n=this._components.length;i < n;i++)
				this._components[i]._setActiveInScene(false);
			}
			this._scene=null;
			for (i=0,n=this._children.length;i < n;i++)
			this._children[i]._setUnBelongScene();
		}
	}

	/**
	*@private
	*/
	__proto._activeHierarchy=function(){
		this._setBit(0x02,true);
		if (this._components){
			for (var i=0,n=this._components.length;i < n;i++)
			this._components[i]._setActive(true);
		}
		this._onActive();
		for (i=0,n=this._children.length;i < n;i++){
			var child=this._children[i];
			(!child._getBit(0x01))&& (child._activeHierarchy());
		}
		if (!this._getBit(0x04)){
			this._setBit(0x04,true);
			this.onAwake();
		}
		this.onEnable();
	}

	/**
	*组件被激活后执行，此时所有节点和组件均已创建完毕，次方法只执行一次
	*此方法为虚方法，使用时重写覆盖即可
	*/
	__proto.onAwake=function(){}
	/**
	*组件被启用后执行，比如节点被添加到舞台后
	*此方法为虚方法，使用时重写覆盖即可
	*/
	__proto.onEnable=function(){}
	/**
	*@private
	*/
	__proto._inActiveHierarchy=function(){
		this._onInActive();
		if (this._components){
			for (var i=0,n=this._components.length;i < n;i++)
			this._components[i]._setActive(false);
		}
		this._setBit(0x02,false);
		for (i=0,n=this._children.length;i < n;i++){
			var child=this._children[i];
			(!child._getBit(0x01))&& (child._inActiveHierarchy());
		}
		this.onDisable();
	}

	/**
	*组件被禁用时执行，比如从节点从舞台移除后
	*此方法为虚方法，使用时重写覆盖即可
	*/
	__proto.onDisable=function(){}
	/**
	*@private
	*/
	__proto._onAdded=function(){
		var parentScene=this._parent.scene;
		parentScene && this._setBelongScene(parentScene);
		(this._parent.activeInHierarchy && this.active)&& this._activeHierarchy();
	}

	/**
	*@private
	*/
	__proto._onRemoved=function(){
		(this._parent.activeInHierarchy && this.active)&& this._inActiveHierarchy();
		this._parent.scene && this._setUnBelongScene();
	}

	/**
	*@private
	*/
	__proto._addComponentInstance=function(comp){this._components=this._components|| [];
		this._components.push(comp);
		comp.owner=this;
		comp._onAdded();
		this.activeInHierarchy && comp._setActive(true);
		this._scene && comp._setActiveInScene(true);
	}

	/**
	*@private
	*/
	__proto._destroyComponent=function(comp){
		if (this._components){
			for (var i=0,n=this._components.length;i < n;i++){
				var item=this._components[i];
				if (item===comp){
					item._destroy();
					this._components.splice(i,1);
					break ;
				}
			}
		}
	}

	/**
	*@private
	*/
	__proto._destroyAllComponent=function(){
		if (this._components){
			for (var i=0,n=this._components.length;i < n;i++){
				var item=this._components[i];
				item._destroy();
			}
			this._components.length=0;
		}
	}

	/**
	*@private 克隆。
	*@param destObject 克隆源。
	*/
	__proto._cloneTo=function(destObject){
		var destNode=destObject;
		if (this._components){
			for (var i=0,n=this._components.length;i < n;i++){
				var destComponent=destNode.addComponent(this._components[i].constructor);
				this._components[i]._cloneTo(destComponent);
			}
		}
	}

	/**
	*添加组件实例。
	*@param comp 组件实例。
	*@return 组件。
	*/
	__proto.addComponentIntance=function(comp){
		if (comp.owner)
			throw "Node:the component has belong to other node.";
		if (comp.isSingleton && this.getComponent((comp).constructor))
			throw "Node:the component is singleton,can't add the second one.";
		this._addComponentInstance(comp);
		return comp;
	}

	/**
	*添加组件。
	*@param type 组件类型。
	*@return 组件。
	*/
	__proto.addComponent=function(type){
		var comp=Pool.createByClass(type);
		comp._destroyed=false;
		if (comp.isSingleton && this.getComponent(type))
			throw "无法实例"+type+"组件"+"，"+type+"组件已存在！";
		this._addComponentInstance(comp);
		return comp;
	}

	/**
	*获得组件实例，如果没有则返回为null
	*@param clas 组建类型
	*@return 返回组件
	*/
	__proto.getComponent=function(clas){
		if (this._components){
			for (var i=0,n=this._components.length;i < n;i++){
				var comp=this._components[i];
				if (Laya.__typeof(comp,clas))
					return comp;
			}
		}
		return null;
	}

	/**
	*获得组件实例，如果没有则返回为null
	*@param clas 组建类型
	*@return 返回组件数组
	*/
	__proto.getComponents=function(clas){
		var arr;
		if (this._components){
			for (var i=0,n=this._components.length;i < n;i++){
				var comp=this._components[i];
				if (Laya.__typeof(comp,clas)){arr=arr|| [];
					arr.push(comp);
				}
			}
		}
		return arr;
	}

	/**
	*子对象数量。
	*/
	__getset(0,__proto,'numChildren',function(){
		return this._children.length;
	});

	/**父节点。*/
	__getset(0,__proto,'parent',function(){
		return this._parent;
	});

	/**
	*获取在场景中是否激活。
	*@return 在场景中是否激活。
	*/
	__getset(0,__proto,'activeInHierarchy',function(){
		return this._getBit(0x02);
	});

	/**
	*设置是否激活。
	*@param value 是否激活。
	*/
	/**
	*获取自身是否激活。
	*@return 自身是否激活。
	*/
	__getset(0,__proto,'active',function(){
		return !this._getBit(0x08)&& !this._getBit(0x01);
		},function(value){
		if (!this._getBit(0x01)!==value){
			this._setBit(0x01,!value);
			if (this._parent){
				if (this._parent.activeInHierarchy){
					if (value)this._activeHierarchy();
					else this._inActiveHierarchy();
				}
			}
		}
	});

	/**表示是否在显示列表中显示。*/
	__getset(0,__proto,'displayedInStage',function(){
		if (this._getBit(0x10))return this._getBit(0x80);
		this._setBitUp(0x10);
		return this._getBit(0x80);
	});

	/**
	*获得所属场景。
	*@return 场景。
	*/
	__getset(0,__proto,'scene',function(){
		return this._scene;
	});

	/**
	*@private
	*获取timer
	*/
	__getset(0,__proto,'timer',function(){
		return this.scene ? this.scene.timer :Laya.timer;
	});

	Node.ARRAY_EMPTY=[];
	return Node;
})(EventDispatcher)


//class laya.net.LoaderManager extends laya.events.EventDispatcher
var LoaderManager=(function(_super){
	var ResInfo;
	function LoaderManager(){
		/**加载出错后的重试次数，默认重试一次*/
		this.retryNum=1;
		/**延迟时间多久再进行错误重试，默认立即重试*/
		this.retryDelay=0;
		/**最大下载线程，默认为5个*/
		this.maxLoader=5;
		/**@private */
		this._loaders=[];
		/**@private */
		this._loaderCount=0;
		/**@private */
		this._resInfos=[];
		/**@private */
		this._infoPool=[];
		/**@private */
		this._maxPriority=5;
		/**@private */
		this._failRes={};
		/**@private */
		this._statInfo={count:1,loaded:1};
		LoaderManager.__super.call(this);
		for (var i=0;i < this._maxPriority;i++)this._resInfos[i]=[];
	}

	__class(LoaderManager,'laya.net.LoaderManager',_super);
	var __proto=LoaderManager.prototype;
	/**@private */
	__proto.getProgress=function(){
		return this._statInfo.loaded / this._statInfo.count;
	}

	/**@private */
	__proto.resetProgress=function(){
		this._statInfo.count=this._statInfo.loaded=1;
	}

	/**
	*<p>根据clas类型创建一个未初始化资源的对象，随后进行异步加载，资源加载完成后，初始化对象的资源，并通过此对象派发 Event.LOADED 事件，事件回调参数值为此对象本身。套嵌资源的子资源会保留资源路径"?"后的部分。</p>
	*<p>如果url为数组，返回true；否则返回指定的资源类对象，可以通过侦听此对象的 Event.LOADED 事件来判断资源是否已经加载完毕。</p>
	*<p><b>注意：</b>cache参数只能对文件后缀为atlas的资源进行缓存控制，其他资源会忽略缓存，强制重新加载。</p>
	*@param url 资源地址或者数组。如果url和clas同时指定了资源类型，优先使用url指定的资源类型。参数形如：[{url:xx,clas:xx,priority:xx,params:xx},{url:xx,clas:xx,priority:xx,params:xx}]。
	*@param complete 加载结束回调。根据url类型不同分为2种情况：1. url为String类型，也就是单个资源地址，如果加载成功，则回调参数值为加载完成的资源，否则为null；2. url为数组类型，指定了一组要加载的资源，如果全部加载成功，则回调参数值为true，否则为false。
	*@param progress 资源加载进度回调，回调参数值为当前资源加载的进度信息(0-1)。
	*@param type 资源类型。
	*@param constructParams 资源构造函数参数。
	*@param propertyParams 资源属性参数。
	*@param priority (default=1)加载的优先级，优先级高的优先加载。有0-4共5个优先级，0最高，4最低。
	*@param cache 是否缓存加载的资源。
	*@return 如果url为数组，返回true；否则返回指定的资源类对象。
	*/
	__proto.create=function(url,complete,progress,type,constructParams,propertyParams,priority,cache){
		(priority===void 0)&& (priority=1);
		(cache===void 0)&& (cache=true);
		this._create(url,true,complete,progress,type,constructParams,propertyParams,priority,cache);
	}

	/**
	*@private
	*/
	__proto._create=function(url,mainResou,complete,progress,type,constructParams,propertyParams,priority,cache){
		(priority===void 0)&& (priority=1);
		(cache===void 0)&& (cache=true);
		if ((url instanceof Array)){
			var items=url;
			var itemCount=items.length;
			var loadedCount=0;
			if (progress){
				var progress2=Handler.create(progress.caller,progress.method,progress.args,false);
			}
			for (var i=0;i < itemCount;i++){
				var item=items[i];
				if ((typeof item=='string'))
					item=items[i]={url:item};
				item.progress=0;
			}
			for (i=0;i < itemCount;i++){
				item=items[i];
				var progressHandler=progress ? Handler.create(null,onProgress,[item],false):null;
				var completeHandler=(progress || complete)? Handler.create(null,onComplete,[item]):null;
				this._createOne(item.url,mainResou,completeHandler,progressHandler,item.type || type,item.constructParams || constructParams,item.propertyParams || propertyParams,item.priority || priority,cache);
			}
			function onComplete (item,content){
				loadedCount++;
				item.progress=1;
				if (loadedCount===itemCount && complete){
					complete.run();
				}
			}
			function onProgress (item,value){
				item.progress=value;
				var num=0;
				for (var j=0;j < itemCount;j++){
					var item1=items[j];
					num+=item1.progress;
				};
				var v=num / itemCount;
				progress2.runWith(v);
			}
			}else {
			this._createOne(url,mainResou,complete,progress,type,constructParams,propertyParams,priority,cache);
		}
	}

	/**
	*@private
	*/
	__proto._createOne=function(url,mainResou,complete,progress,type,constructParams,propertyParams,priority,cache){
		(priority===void 0)&& (priority=1);
		(cache===void 0)&& (cache=true);
		var item=this.getRes(url);
		if (!item){
			var extension=Utils.getFileExtension(url);
			(type)|| (type=LoaderManager.createMap[extension]? LoaderManager.createMap[extension][0]:null);
			if (!type){
				this.load(url,complete,progress,type,priority,cache);
				return;
			};
			var parserMap=Loader.parserMap;
			if (!parserMap[type]){
				this.load(url,complete,progress,type,priority,cache);
				return;
			}
			this._createLoad(url,Handler.create(null,onLoaded),progress,type,constructParams,propertyParams,priority,cache,true);
			function onLoaded (item){
				if (!mainResou && (item instanceof laya.resource.Resource ))
					item._addReference();
				complete && complete.runWith(item);
				Laya.loader.event(url);
			};
			}else {
			if (!mainResou && (item instanceof laya.resource.Resource ))
				item._addReference();
			progress && progress.runWith(1);
			complete && complete.runWith(item);
		}
	}

	/**
	*<p>加载资源。资源加载错误时，本对象会派发 Event.ERROR 事件，事件回调参数值为加载出错的资源地址。</p>
	*<p>因为返回值为 LoaderManager 对象本身，所以可以使用如下语法：loaderManager.load(...).load(...);</p>
	*@param url 要加载的单个资源地址或资源信息数组。比如：简单数组：["a.png","b.png"]；复杂数组[{url:"a.png",type:Loader.IMAGE,size:100,priority:1},{url:"b.json",type:Loader.JSON,size:50,priority:1}]。
	*@param complete 加载结束回调。根据url类型不同分为2种情况：1. url为String类型，也就是单个资源地址，如果加载成功，则回调参数值为加载完成的资源，否则为null；2. url为数组类型，指定了一组要加载的资源，如果全部加载成功，则回调参数值为true，否则为false。
	*@param progress 加载进度回调。回调参数值为当前资源的加载进度信息(0-1)。
	*@param type 资源类型。比如：Loader.IMAGE。
	*@param priority (default=1)加载的优先级，优先级高的优先加载。有0-4共5个优先级，0最高，4最低。
	*@param cache 是否缓存加载结果。
	*@param group 分组，方便对资源进行管理。
	*@param ignoreCache 是否忽略缓存，强制重新加载。
	*@param useWorkerLoader(default=false)是否使用worker加载（只针对IMAGE类型和ATLAS类型，并且浏览器支持的情况下生效）
	*@return 此 LoaderManager 对象本身。
	*/
	__proto.load=function(url,complete,progress,type,priority,cache,group,ignoreCache,useWorkerLoader){
		var _$this=this;
		(priority===void 0)&& (priority=1);
		(cache===void 0)&& (cache=true);
		(ignoreCache===void 0)&& (ignoreCache=false);
		(useWorkerLoader===void 0)&& (useWorkerLoader=false);
		if ((url instanceof Array))return this._loadAssets(url,complete,progress,type,priority,cache,group);
		var content=Loader.getRes(url);
		if (!ignoreCache && content !=null){
			Laya.systemTimer.frameOnce(1,null,function(){
				progress && progress.runWith(1);
				complete && complete.runWith(content);
				_$this._loaderCount || _$this.event("complete");
			});
			}else {
			var original;
			original=url;
			url=AtlasInfoManager.getFileLoadPath(url);
			if (url !=original && type!=="nativeimage"){
				type="atlas";
				}else {
				original=null;
			};
			var info=LoaderManager._resMap[url];
			if (!info){
				info=this._infoPool.length ? this._infoPool.pop():new ResInfo();
				info.url=url;
				info.type=type;
				info.cache=cache;
				info.group=group;
				info.ignoreCache=ignoreCache;
				info.useWorkerLoader=useWorkerLoader;
				info.originalUrl=original;
				complete && info.on("complete",complete.caller,complete.method,complete.args);
				progress && info.on("progress",progress.caller,progress.method,progress.args);
				LoaderManager._resMap[url]=info;
				priority=priority < this._maxPriority ? priority :this._maxPriority-1;
				this._resInfos[priority].push(info);
				this._statInfo.count++;
				this.event("progress",this.getProgress());
				this._next();
				}else {
				if (complete){
					if (original){
						complete && info._createListener("complete",this,this._resInfoLoaded,[original,complete],false,false);
						}else {
						complete && info._createListener("complete",complete.caller,complete.method,complete.args,false,false);
					}
				}
				progress && info._createListener("progress",progress.caller,progress.method,progress.args,false,false);
			}
		}
		return this;
	}

	__proto._resInfoLoaded=function(original,complete){
		complete.runWith(Loader.getRes(original));
	}

	/**
	*@private
	*/
	__proto._createLoad=function(url,complete,progress,type,constructParams,propertyParams,priority,cache,ignoreCache){
		var _$this=this;
		(priority===void 0)&& (priority=1);
		(cache===void 0)&& (cache=true);
		(ignoreCache===void 0)&& (ignoreCache=false);
		if ((url instanceof Array))return this._loadAssets(url,complete,progress,type,priority,cache);
		var content=Loader.getRes(url);
		if (content !=null){
			Laya.systemTimer.frameOnce(1,null,function(){
				progress && progress.runWith(1);
				complete && complete.runWith(content);
				_$this._loaderCount || _$this.event("complete");
			});
			}else {
			var info=LoaderManager._resMap[url];
			if (!info){
				info=this._infoPool.length ? this._infoPool.pop():new ResInfo();
				info.url=url;
				info.type=type;
				info.cache=false;
				info.ignoreCache=ignoreCache;
				info.originalUrl=null;
				info.createCache=cache;
				info.createConstructParams=constructParams;
				info.createPropertyParams=propertyParams;
				complete && info.on("complete",complete.caller,complete.method,complete.args);
				progress && info.on("progress",progress.caller,progress.method,progress.args);
				LoaderManager._resMap[url]=info;
				priority=priority < this._maxPriority ? priority :this._maxPriority-1;
				this._resInfos[priority].push(info);
				this._statInfo.count++;
				this.event("progress",this.getProgress());
				this._next();
				}else {
				complete && info._createListener("complete",complete.caller,complete.method,complete.args,false,false);
				progress && info._createListener("progress",progress.caller,progress.method,progress.args,false,false);
			}
		}
		return this;
	}

	__proto._next=function(){
		if (this._loaderCount >=this.maxLoader)return;
		for (var i=0;i < this._maxPriority;i++){
			var infos=this._resInfos[i];
			while (infos.length > 0){
				var info=infos.shift();
				if (info)return this._doLoad(info);
			}
		}
		this._loaderCount || this.event("complete");
	}

	__proto._doLoad=function(resInfo){
		this._loaderCount++;
		var loader=this._loaders.length ? this._loaders.pop():new Loader();
		loader.on("complete",null,onLoaded);
		loader.on("progress",null,function(num){
			resInfo.event("progress",num);
		});
		loader.on("error",null,function(msg){
			onLoaded(null);
		});
		var _me=this;
		function onLoaded (data){
			loader.offAll();
			loader._data=null;
			loader._customParse=false;
			_me._loaders.push(loader);
			_me._endLoad(resInfo,(data instanceof Array)? [data] :data);
			_me._loaderCount--;
			_me._next();
		}
		loader._constructParams=resInfo.createConstructParams;
		loader._propertyParams=resInfo.createPropertyParams;
		loader._createCache=resInfo.createCache;
		loader.load(resInfo.url,resInfo.type,resInfo.cache,resInfo.group,resInfo.ignoreCache,resInfo.useWorkerLoader);
	}

	__proto._endLoad=function(resInfo,content){
		var url=resInfo.url;
		if (content==null){
			var errorCount=this._failRes[url] || 0;
			if (errorCount < this.retryNum){
				console.warn("[warn]Retry to load:",url);
				this._failRes[url]=errorCount+1;
				Laya.systemTimer.once(this.retryDelay,this,this._addReTry,[resInfo],false);
				return;
				}else {
				Loader.clearRes(url);
				console.warn("[error]Failed to load:",url);
				this.event("error",url);
			}
		}
		if (this._failRes[url])this._failRes[url]=0;
		delete LoaderManager._resMap[url];
		if (resInfo.originalUrl){
			content=Loader.getRes(resInfo.originalUrl);
		}
		resInfo.event("complete",content);
		resInfo.offAll();
		this._infoPool.push(resInfo);
		this._statInfo.loaded++;
		this.event("progress",this.getProgress());
	}

	__proto._addReTry=function(resInfo){
		this._resInfos[this._maxPriority-1].push(resInfo);
		this._next();
	}

	/**
	*清理指定资源地址缓存。
	*@param url 资源地址。
	*/
	__proto.clearRes=function(url){
		Loader.clearRes(url);
	}

	/**
	*销毁Texture使用的图片资源，保留texture壳，如果下次渲染的时候，发现texture使用的图片资源不存在，则会自动恢复
	*相比clearRes，clearTextureRes只是清理texture里面使用的图片资源，并不销毁texture，再次使用到的时候会自动恢复图片资源
	*而clearRes会彻底销毁texture，导致不能再使用；clearTextureRes能确保立即销毁图片资源，并且不用担心销毁错误，clearRes则采用引用计数方式销毁
	*【注意】如果图片本身在自动合集里面（默认图片小于512*512），内存是不能被销毁的，此图片被大图合集管理器管理
	*@param url 图集地址或者texture地址，比如 Loader.clearTextureRes("res/atlas/comp.atlas");Loader.clearTextureRes("hall/bg.jpg");
	*/
	__proto.clearTextureRes=function(url){
		Loader.clearTextureRes(url);
	}

	/**
	*获取指定资源地址的资源。
	*@param url 资源地址。
	*@return 返回资源。
	*/
	__proto.getRes=function(url){
		return Loader.getRes(url);
	}

	/**
	*缓存资源。
	*@param url 资源地址。
	*@param data 要缓存的内容。
	*/
	__proto.cacheRes=function(url,data){
		Loader.cacheRes(url,data);
	}

	/**
	*设置资源分组。
	*@param url 资源地址。
	*@param group 分组名
	*/
	__proto.setGroup=function(url,group){
		Loader.setGroup(url,group);
	}

	/**
	*根据分组清理资源。
	*@param group 分组名
	*/
	__proto.clearResByGroup=function(group){
		Loader.clearResByGroup(group);
	}

	/**清理当前未完成的加载，所有未加载的内容全部停止加载。*/
	__proto.clearUnLoaded=function(){
		for (var i=0;i < this._maxPriority;i++){
			var infos=this._resInfos[i];
			for (var j=infos.length-1;j >-1;j--){
				var info=infos[j];
				if (info){
					info.offAll();
					this._infoPool.push(info);
				}
			}
			infos.length=0;
		}
		this._loaderCount=0;
		LoaderManager._resMap={};
	}

	/**
	*根据地址集合清理掉未加载的内容
	*@param urls 资源地址集合
	*/
	__proto.cancelLoadByUrls=function(urls){
		if (!urls)return;
		for (var i=0,n=urls.length;i < n;i++){
			this.cancelLoadByUrl(urls[i]);
		}
	}

	/**
	*根据地址清理掉未加载的内容
	*@param url 资源地址
	*/
	__proto.cancelLoadByUrl=function(url){
		for (var i=0;i < this._maxPriority;i++){
			var infos=this._resInfos[i];
			for (var j=infos.length-1;j >-1;j--){
				var info=infos[j];
				if (info && info.url===url){
					infos[j]=null;
					info.offAll();
					this._infoPool.push(info);
				}
			}
		}
		if (LoaderManager._resMap[url])delete LoaderManager._resMap[url];
	}

	/**
	*@private
	*加载数组里面的资源。
	*@param arr 简单：["a.png","b.png"]，复杂[{url:"a.png",type:Loader.IMAGE,size:100,priority:1,useWorkerLoader:true},{url:"b.json",type:Loader.JSON,size:50,priority:1}]*/
	__proto._loadAssets=function(arr,complete,progress,type,priority,cache,group){
		(priority===void 0)&& (priority=1);
		(cache===void 0)&& (cache=true);
		var itemCount=arr.length;
		var loadedCount=0;
		var totalSize=0;
		var items=[];
		var success=true;
		for (var i=0;i < itemCount;i++){
			var item=arr[i];
			if ((typeof item=='string'))item={url:item,type:type,size:1,priority:priority};
			if (!item.size)item.size=1;
			item.progress=0;
			totalSize+=item.size;
			items.push(item);
			var progressHandler=progress ? Handler.create(null,loadProgress,[item],false):null;
			var completeHandler=(complete || progress)? Handler.create(null,loadComplete,[item]):null;
			this.load(item.url,completeHandler,progressHandler,item.type,item.priority || 1,cache,item.group || group,false,item.useWorkerLoader);
		}
		function loadComplete (item,content){
			loadedCount++;
			item.progress=1;
			if (!content)success=false;
			if (loadedCount===itemCount && complete){
				complete.runWith(success);
			}
		}
		function loadProgress (item,value){
			if (progress !=null){
				item.progress=value;
				var num=0;
				for (var j=0;j < items.length;j++){
					var item1=items[j];
					num+=item1.size *item1.progress;
				};
				var v=num / totalSize;
				progress.runWith(v);
			}
		}
		return this;
	}

	//TODO:TESTs
	__proto.decodeBitmaps=function(urls){
		var i=0,len=urls.length;
		var ctx;
		ctx=Render._context;
		for (i=0;i < len;i++){
			var atlas;
			atlas=Loader.getAtlas(urls[i]);
			if (atlas){
				this._decodeTexture(atlas[0],ctx);
				}else {
				var tex;
				tex=this.getRes(urls[i]);
				if (tex && (tex instanceof laya.resource.Texture )){
					this._decodeTexture(tex,ctx);
				}
			}
		}
	}

	__proto._decodeTexture=function(tex,ctx){
		var bitmap=tex.bitmap;
		if (!tex || !bitmap)return;
		var tImg=bitmap.source || bitmap.image;
		if (!tImg)return;
		if (Laya.__typeof(tImg,Browser.window.HTMLImageElement)){
			ctx.drawImage(tImg,0,0,1,1);
			var info=ctx.getImageData(0,0,1,1);
		}
	}

	LoaderManager.cacheRes=function(url,data){
		Loader.cacheRes(url,data);
	}

	LoaderManager._resMap={};
	__static(LoaderManager,
	['createMap',function(){return this.createMap={atlas:[null,"atlas"]};}
	]);
	LoaderManager.__init$=function(){
		//class ResInfo extends laya.events.EventDispatcher
		ResInfo=(function(_super){
			function ResInfo(){
				this.url=null;
				this.type=null;
				this.cache=false;
				this.group=null;
				this.ignoreCache=false;
				this.useWorkerLoader=false;
				this.originalUrl=null;
				this.createCache=false;
				this.createConstructParams=null;
				this.createPropertyParams=null;
				ResInfo.__super.call(this);
			}
			__class(ResInfo,'',_super);
			return ResInfo;
		})(EventDispatcher)
	}

	return LoaderManager;
})(EventDispatcher)


//class laya.media.h5audio.AudioSound extends laya.events.EventDispatcher
var AudioSound=(function(_super){
	function AudioSound(){
		/**
		*声音URL
		*/
		this.url=null;
		/**
		*播放用的audio标签
		*/
		this.audio=null;
		/**
		*是否已加载完成
		*/
		this.loaded=false;
		AudioSound.__super.call(this);
	}

	__class(AudioSound,'laya.media.h5audio.AudioSound',_super);
	var __proto=AudioSound.prototype;
	/**
	*释放声音
	*
	*/
	__proto.dispose=function(){
		var ad=AudioSound._audioCache[this.url];
		if (ad){
			ad.src="";
			delete AudioSound._audioCache[this.url];
		}
	}

	/**
	*加载声音
	*@param url
	*
	*/
	__proto.load=function(url){
		url=URL.formatURL(url);
		this.url=url;
		var ad;
		if (url==SoundManager._bgMusic){
			AudioSound._initMusicAudio();
			ad=AudioSound._musicAudio;
			if (ad.src !=url){
				AudioSound._audioCache[ad.src]=null;
				ad=null;
			}
			}else{
			ad=AudioSound._audioCache[url];
		}
		if (ad && ad.readyState >=2){
			this.event("complete");
			return;
		}
		if (!ad){
			if (url==SoundManager._bgMusic){
				AudioSound._initMusicAudio();
				ad=AudioSound._musicAudio;
				}else{
				ad=Browser.createElement("audio");
			}
			AudioSound._audioCache[url]=ad;
			ad.src=url;
		}
		ad.addEventListener("canplaythrough",onLoaded);
		ad.addEventListener("error",onErr);
		var me=this;
		function onLoaded (){
			offs();
			me.loaded=true;
			me.event("complete");
		}
		function onErr (){
			ad.load=null;
			offs();
			me.event("error");
		}
		function offs (){
			ad.removeEventListener("canplaythrough",onLoaded);
			ad.removeEventListener("error",onErr);
		}
		this.audio=ad;
		if (ad.load){
			ad.load();
			}else {
			onErr();
		}
	}

	/**
	*播放声音
	*@param startTime 起始时间
	*@param loops 循环次数
	*@return
	*
	*/
	__proto.play=function(startTime,loops){
		(startTime===void 0)&& (startTime=0);
		(loops===void 0)&& (loops=0);
		if (!this.url)return null;
		var ad;
		if (this.url==SoundManager._bgMusic){
			ad=AudioSound._musicAudio;
			}else{
			ad=AudioSound._audioCache[this.url];
		}
		if (!ad)return null;
		var tAd;
		tAd=Pool.getItem("audio:"+this.url);
		if (Render.isConchApp){
			if (!tAd){
				tAd=Browser.createElement("audio");
				tAd.src=this.url;
			}
		}
		else {
			if (this.url==SoundManager._bgMusic){
				AudioSound._initMusicAudio();
				tAd=AudioSound._musicAudio;
				tAd.src=this.url;
				}else{
				tAd=tAd ? tAd :ad.cloneNode(true);
			}
		};
		var channel=new AudioSoundChannel(tAd);
		channel.url=this.url;
		channel.loops=loops;
		channel.startTime=startTime;
		channel.play();
		SoundManager.addChannel(channel);
		return channel;
	}

	/**
	*获取总时间。
	*/
	__getset(0,__proto,'duration',function(){
		var ad;
		ad=AudioSound._audioCache[this.url];
		if (!ad)
			return 0;
		return ad.duration;
	});

	AudioSound._initMusicAudio=function(){
		if (AudioSound._musicAudio)return;
		if (!AudioSound._musicAudio)AudioSound._musicAudio=Browser.createElement("audio");
		if (!Render.isConchApp){
			Browser.document.addEventListener("mousedown",AudioSound._makeMusicOK);
		}
	}

	AudioSound._makeMusicOK=function(){
		Browser.document.removeEventListener("mousedown",AudioSound._makeMusicOK);
		if (!AudioSound._musicAudio.src){
			AudioSound._musicAudio.src="";
			AudioSound._musicAudio.load();
			}else{
			AudioSound._musicAudio.play();
		}
	}

	AudioSound._audioCache={};
	AudioSound._musicAudio=null;
	return AudioSound;
})(EventDispatcher)


//class laya.media.SoundChannel extends laya.events.EventDispatcher
var SoundChannel=(function(_super){
	function SoundChannel(){
		/**
		*声音地址。
		*/
		this.url=null;
		/**
		*循环次数。
		*/
		this.loops=0;
		/**
		*播放声音开始时间。
		*/
		this.startTime=NaN;
		/**
		*表示声音是否已暂停。
		*/
		this.isStopped=false;
		/**
		*播放完成处理器。
		*/
		this.completeHandler=null;
		SoundChannel.__super.call(this);
	}

	__class(SoundChannel,'laya.media.SoundChannel',_super);
	var __proto=SoundChannel.prototype;
	/**
	*播放声音。
	*/
	__proto.play=function(){}
	/**
	*停止播放。
	*/
	__proto.stop=function(){}
	/**
	*暂停播放。
	*/
	__proto.pause=function(){}
	/**
	*继续播放。
	*/
	__proto.resume=function(){}
	/**
	*private
	*/
	__proto.__runComplete=function(handler){
		if (handler){
			handler.run();
		}
	}

	/**
	*音量范围从 0（静音）至 1（最大音量）。
	*/
	__getset(0,__proto,'volume',function(){
		return 1;
		},function(v){
	});

	/**
	*获取当前播放时间，单位是秒。
	*/
	__getset(0,__proto,'position',function(){
		return 0;
	});

	/**
	*获取总时间，单位是秒。
	*/
	__getset(0,__proto,'duration',function(){
		return 0;
	});

	return SoundChannel;
})(EventDispatcher)


//class laya.media.Sound extends laya.events.EventDispatcher
var Sound=(function(_super){
	function Sound(){
		Sound.__super.call(this);;
	}

	__class(Sound,'laya.media.Sound',_super);
	var __proto=Sound.prototype;
	/**
	*加载声音。
	*@param url 地址。
	*/
	__proto.load=function(url){}
	/**
	*播放声音。
	*@param startTime 开始时间,单位秒
	*@param loops 循环次数,0表示一直循环
	*@return 声道 SoundChannel 对象。
	*/
	__proto.play=function(startTime,loops){
		(startTime===void 0)&& (startTime=0);
		(loops===void 0)&& (loops=0);
		return null;
	}

	/**
	*释放声音资源。
	*/
	__proto.dispose=function(){}
	/**
	*获取总时间。
	*/
	__getset(0,__proto,'duration',function(){
		return 0;
	});

	return Sound;
})(EventDispatcher)


//class laya.media.webaudio.WebAudioSound extends laya.events.EventDispatcher
var WebAudioSound=(function(_super){
	function WebAudioSound(){
		/**
		*声音URL
		*/
		this.url=null;
		/**
		*是否已加载完成
		*/
		this.loaded=false;
		/**
		*声音文件数据
		*/
		this.data=null;
		/**
		*声音原始文件数据
		*/
		this.audioBuffer=null;
		/**
		*待播放的声音列表
		*/
		this.__toPlays=null;
		/**
		*@private
		*/
		this._disposed=false;
		WebAudioSound.__super.call(this);
	}

	__class(WebAudioSound,'laya.media.webaudio.WebAudioSound',_super);
	var __proto=WebAudioSound.prototype;
	/**
	*加载声音
	*@param url
	*
	*/
	__proto.load=function(url){
		var me=this;
		url=URL.formatURL(url);
		this.url=url;
		this.audioBuffer=WebAudioSound._dataCache[url];
		if (this.audioBuffer){
			this._loaded(this.audioBuffer);
			return;
		}
		WebAudioSound.e.on("loaded:"+url,this,this._loaded);
		WebAudioSound.e.on("err:"+url,this,this._err);
		if (WebAudioSound.__loadingSound[url]){
			return;
		}
		WebAudioSound.__loadingSound[url]=true;
		var request=new Browser.window.XMLHttpRequest();
		request.open("GET",url,true);
		request.responseType="arraybuffer";
		request.onload=function (){
			if (me._disposed){
				me._removeLoadEvents();
				return;
			}
			me.data=request.response;
			WebAudioSound.buffs.push({"buffer":me.data,"url":me.url});
			WebAudioSound.decode();
		};
		request.onerror=function (e){
			me._err();
		}
		request.send();
	}

	__proto._err=function(){
		this._removeLoadEvents();
		WebAudioSound.__loadingSound[this.url]=false;
		this.event("error");
	}

	__proto._loaded=function(audioBuffer){
		this._removeLoadEvents();
		if (this._disposed){
			return;
		}
		this.audioBuffer=audioBuffer;
		WebAudioSound._dataCache[this.url]=this.audioBuffer;
		this.loaded=true;
		this.event("complete");
	}

	__proto._removeLoadEvents=function(){
		WebAudioSound.e.off("loaded:"+this.url,this,this._loaded);
		WebAudioSound.e.off("err:"+this.url,this,this._err);
	}

	__proto.__playAfterLoaded=function(){
		if (!this.__toPlays)return;
		var i=0,len=0;
		var toPlays;
		toPlays=this.__toPlays;
		len=toPlays.length;
		var tParams;
		for (i=0;i < len;i++){
			tParams=toPlays[i];
			if (tParams[2] && !(tParams [2]).isStopped){
				this.play(tParams[0],tParams[1],tParams[2]);
			}
		}
		this.__toPlays.length=0;
	}

	/**
	*播放声音
	*@param startTime 起始时间
	*@param loops 循环次数
	*@return
	*
	*/
	__proto.play=function(startTime,loops,channel){
		(startTime===void 0)&& (startTime=0);
		(loops===void 0)&& (loops=0);
		channel=channel ? channel :new WebAudioSoundChannel();
		if (!this.audioBuffer){
			if (this.url){
				if (!this.__toPlays)this.__toPlays=[];
				this.__toPlays.push([startTime,loops,channel]);
				this.once("complete",this,this.__playAfterLoaded);
				this.load(this.url);
			}
		}
		channel.url=this.url;
		channel.loops=loops;
		channel["audioBuffer"]=this.audioBuffer;
		channel.startTime=startTime;
		channel.play();
		SoundManager.addChannel(channel);
		return channel;
	}

	__proto.dispose=function(){
		this._disposed=true;
		delete WebAudioSound._dataCache[this.url];
		delete WebAudioSound.__loadingSound[this.url];
		this.audioBuffer=null;
		this.data=null;
		this.__toPlays=[];
	}

	__getset(0,__proto,'duration',function(){
		if (this.audioBuffer){
			return this.audioBuffer.duration;
		}
		return 0;
	});

	WebAudioSound.decode=function(){
		if (WebAudioSound.buffs.length <=0 || WebAudioSound.isDecoding){
			return;
		}
		WebAudioSound.isDecoding=true;
		WebAudioSound.tInfo=WebAudioSound.buffs.shift();
		WebAudioSound.ctx.decodeAudioData(WebAudioSound.tInfo["buffer"],WebAudioSound._done,WebAudioSound._fail);
	}

	WebAudioSound._done=function(audioBuffer){
		WebAudioSound.e.event("loaded:"+WebAudioSound.tInfo.url,audioBuffer);
		WebAudioSound.isDecoding=false;
		WebAudioSound.decode();
	}

	WebAudioSound._fail=function(){
		WebAudioSound.e.event("err:"+WebAudioSound.tInfo.url,null);
		WebAudioSound.isDecoding=false;
		WebAudioSound.decode();
	}

	WebAudioSound._playEmptySound=function(){
		if (WebAudioSound.ctx==null){
			return;
		};
		var source=WebAudioSound.ctx.createBufferSource();
		source.buffer=WebAudioSound._miniBuffer;
		source.connect(WebAudioSound.ctx.destination);
		source.start(0,0,0);
	}

	WebAudioSound._unlock=function(){
		if (WebAudioSound._unlocked){
			return;
		}
		WebAudioSound._playEmptySound();
		if (WebAudioSound.ctx.state=="running"){
			Browser.document.removeEventListener("mousedown",WebAudioSound._unlock,true);
			Browser.document.removeEventListener("touchend",WebAudioSound._unlock,true);
			Browser.document.removeEventListener("touchstart",WebAudioSound._unlock,true);
			WebAudioSound._unlocked=true;
		}
	}

	WebAudioSound.initWebAudio=function(){
		if (WebAudioSound.ctx.state !="running"){
			WebAudioSound._unlock();
			Browser.document.addEventListener("mousedown",WebAudioSound._unlock,true);
			Browser.document.addEventListener("touchend",WebAudioSound._unlock,true);
			Browser.document.addEventListener("touchstart",WebAudioSound._unlock,true);
		}
	}

	WebAudioSound._dataCache={};
	WebAudioSound.buffs=[];
	WebAudioSound.isDecoding=false;
	WebAudioSound._unlocked=false;
	WebAudioSound.tInfo=null;
	WebAudioSound.__loadingSound={};
	__static(WebAudioSound,
	['window',function(){return this.window=Browser.window;},'webAudioEnabled',function(){return this.webAudioEnabled=WebAudioSound.window["AudioContext"] || WebAudioSound.window["webkitAudioContext"] || WebAudioSound.window["mozAudioContext"];},'ctx',function(){return this.ctx=WebAudioSound.webAudioEnabled ? new (WebAudioSound.window["AudioContext"] || WebAudioSound.window["webkitAudioContext"] || WebAudioSound.window["mozAudioContext"])():undefined;},'_miniBuffer',function(){return this._miniBuffer=WebAudioSound.ctx.createBuffer(1,1,22050);},'e',function(){return this.e=new EventDispatcher();}
	]);
	return WebAudioSound;
})(EventDispatcher)


//class laya.net.HttpRequest extends laya.events.EventDispatcher
var HttpRequest=(function(_super){
	function HttpRequest(){
		/**@private */
		this._responseType=null;
		/**@private */
		this._data=null;
		/**@private */
		this._url=null;
		HttpRequest.__super.call(this);
		this._http=new Browser.window.XMLHttpRequest();
	}

	__class(HttpRequest,'laya.net.HttpRequest',_super);
	var __proto=HttpRequest.prototype;
	/**
	*发送 HTTP 请求。
	*@param url 请求的地址。大多数浏览器实施了一个同源安全策略，并且要求这个 URL 与包含脚本的文本具有相同的主机名和端口。
	*@param data (default=null)发送的数据。
	*@param method (default="get")用于请求的 HTTP 方法。值包括 "get"、"post"、"head"。
	*@param responseType (default="text")Web 服务器的响应类型，可设置为 "text"、"json"、"xml"、"arraybuffer"。
	*@param headers (default=null)HTTP 请求的头部信息。参数形如key-value数组：key是头部的名称，不应该包括空白、冒号或换行；value是头部的值，不应该包括换行。比如["Content-Type","application/json"]。
	*/
	__proto.send=function(url,data,method,responseType,headers){
		(method===void 0)&& (method="get");
		(responseType===void 0)&& (responseType="text");
		this._responseType=responseType;
		this._data=null;
		this._url=url;
		var _this=this;
		var http=this._http;
		url=URL.getAdptedFilePath(url);
		http.open(method,url,true);
		if (headers){
			for (var i=0;i < headers.length;i++){
				http.setRequestHeader(headers[i++],headers[i]);
			}
			}else if (!Render.isConchApp){
			if (!data || (typeof data=='string'))http.setRequestHeader("Content-Type","application/x-www-form-urlencoded");
			else http.setRequestHeader("Content-Type","application/json");
		}
		http.responseType=responseType!=="arraybuffer" ? "text" :"arraybuffer";
		http.onerror=function (e){
			_this._onError(e);
		}
		http.onabort=function (e){
			_this._onAbort(e);
		}
		http.onprogress=function (e){
			_this._onProgress(e);
		}
		http.onload=function (e){
			_this._onLoad(e);
		}
		http.send(data);
	}

	/**
	*@private
	*请求进度的侦听处理函数。
	*@param e 事件对象。
	*/
	__proto._onProgress=function(e){
		if (e && e.lengthComputable)this.event("progress",e.loaded / e.total);
	}

	/**
	*@private
	*请求中断的侦听处理函数。
	*@param e 事件对象。
	*/
	__proto._onAbort=function(e){
		this.error("Request was aborted by user");
	}

	/**
	*@private
	*请求出错侦的听处理函数。
	*@param e 事件对象。
	*/
	__proto._onError=function(e){
		this.error("Request failed Status:"+this._http.status+" text:"+this._http.statusText);
	}

	/**
	*@private
	*请求消息返回的侦听处理函数。
	*@param e 事件对象。
	*/
	__proto._onLoad=function(e){
		var http=this._http;
		var status=http.status!==undefined ? http.status :200;
		if (status===200 || status===204 || status===0){
			this.complete();
			}else {
			this.error("["+http.status+"]"+http.statusText+":"+http.responseURL);
		}
	}

	/**
	*@private
	*请求错误的处理函数。
	*@param message 错误信息。
	*/
	__proto.error=function(message){
		this.clear();
		console.warn(this.url,message);
		this.event("error",message);
	}

	/**
	*@private
	*请求成功完成的处理函数。
	*/
	__proto.complete=function(){
		this.clear();
		var flag=true;
		try {
			if (this._responseType==="json"){
				this._data=JSON.parse(this._http.responseText);
				}else if (this._responseType==="xml"){
				this._data=Utils.parseXMLFromString(this._http.responseText);
				}else {
				this._data=this._http.response || this._http.responseText;
			}
			}catch (e){
			flag=false;
			this.error(e.message);
		}
		flag && this.event("complete",(this._data instanceof Array)? [this._data] :this._data);
	}

	/**
	*@private
	*清除当前请求。
	*/
	__proto.clear=function(){
		var http=this._http;
		http.onerror=http.onabort=http.onprogress=http.onload=null;
	}

	/**请求的地址。*/
	__getset(0,__proto,'url',function(){
		return this._url;
	});

	/**
	*本对象所封装的原生 XMLHttpRequest 引用。
	*/
	__getset(0,__proto,'http',function(){
		return this._http;
	});

	/**返回的数据。*/
	__getset(0,__proto,'data',function(){
		return this._data;
	});

	return HttpRequest;
})(EventDispatcher)


//class laya.net.Loader extends laya.events.EventDispatcher
var Loader=(function(_super){
	function Loader(){
		/**@private 加载后的数据对象，只读*/
		this._data=null;
		/**@private */
		this._url=null;
		/**@private */
		this._type=null;
		/**@private */
		this._cache=false;
		/**@private */
		this._http=null;
		/**@private */
		this._useWorkerLoader=false;
		/**@private 自定义解析不派发complete事件，但会派发loaded事件，手动调用endLoad方法再派发complete事件*/
		this._customParse=false;
		/**@private */
		this._constructParams=null;
		/**@private */
		this._propertyParams=null;
		/**@private */
		this._createCache=false;
		Loader.__super.call(this);
	}

	__class(Loader,'laya.net.Loader',_super);
	var __proto=Loader.prototype;
	/**
	*加载资源。加载错误会派发 Event.ERROR 事件，参数为错误信息。
	*@param url 资源地址。
	*@param type (default=null)资源类型。可选值为：Loader.TEXT、Loader.JSON、Loader.XML、Loader.BUFFER、Loader.IMAGE、Loader.SOUND、Loader.ATLAS、Loader.FONT。如果为null，则根据文件后缀分析类型。
	*@param cache (default=true)是否缓存数据。
	*@param group (default=null)分组名称。
	*@param ignoreCache (default=false)是否忽略缓存，强制重新加载。
	*@param useWorkerLoader(default=false)是否使用worker加载（只针对IMAGE类型和ATLAS类型，并且浏览器支持的情况下生效）
	*/
	__proto.load=function(url,type,cache,group,ignoreCache,useWorkerLoader){
		(cache===void 0)&& (cache=true);
		(ignoreCache===void 0)&& (ignoreCache=false);
		(useWorkerLoader===void 0)&& (useWorkerLoader=false);
		if (!url){
			this.onLoaded(null);
			return;
		}
		Loader.setGroup(url,"666");
		this._url=url;
		if (url.indexOf("data:image")===0)type="image";
		else url=URL.formatURL(url);
		this._type=type || (type=Loader.getTypeFromUrl(url));
		this._cache=cache;
		this._useWorkerLoader=useWorkerLoader;
		this._data=null;
		if (useWorkerLoader)WorkerLoader.enableWorkerLoader();
		if (!ignoreCache && Loader.loadedMap[url]){
			this._data=Loader.loadedMap[url];
			this.event("progress",1);
			this.event("complete",this._data);
			return;
		}
		if (group)Loader.setGroup(url,group);
		if (Loader.parserMap[type] !=null){
			this._customParse=true;
			if (((Loader.parserMap[type])instanceof laya.utils.Handler ))Loader.parserMap[type].runWith(this);
			else Loader.parserMap[type].call(null,this);
			return;
		}
		if (type==="image" || type==="htmlimage" || type==="nativeimage")return this._loadImage(url);
		if (type==="sound")return this._loadSound(url);
		if (type==="ttf")return this._loadTTF(url);
		var contentType;
		switch (type){
			case "atlas":
			case "prefab":
			case "plf":
				contentType="json";
				break ;
			case "font":
				contentType="xml";
				break ;
			default :
				contentType=type;
			}
		if (Loader.preLoadedMap[url]){
			this.onLoaded(Loader.preLoadedMap[url]);
			}else {
			if (!this._http){
				this._http=new HttpRequest();
				this._http.on("progress",this,this.onProgress);
				this._http.on("error",this,this.onError);
				this._http.on("complete",this,this.onLoaded);
			}
			this._http.send(url,null,"get",contentType);
		}
	}

	/**
	*@private
	*加载TTF资源。
	*@param url 资源地址。
	*/
	__proto._loadTTF=function(url){
		url=URL.formatURL(url);
		var ttfLoader=new TTFLoader();
		ttfLoader.complete=Handler.create(this,this.onLoaded);
		ttfLoader.load(url);
	}

	/**
	*@private
	*加载图片资源。
	*@param url 资源地址。
	*/
	__proto._loadImage=function(url){
		url=URL.formatURL(url);
		var _this=this;
		var image;
		function clear (){
			var img=image;
			if (img){
				img.onload=null;
				img.onerror=null;
				delete Loader._imgCache[url];
			}
		};
		var onerror=function (){
			clear();
			_this.event("error","Load image failed");
		}
		if (this._type==="nativeimage"){
			var onload=function (){
				clear();
				_this.onLoaded(image);
			};
			image=new Browser.window.Image();
			image.crossOrigin="";
			image.onload=onload;
			image.onerror=onerror;
			image.src=url;
			Loader._imgCache[url]=image;
			}else {
			var imageSource=new Browser.window.Image();
			onload=function (){
				image=HTMLImage.create(imageSource.width,imageSource.height);
				image.loadImageSource(imageSource,true);
				image._setUrl(url);
				clear();
				_this.onLoaded(image);
			};
			imageSource.crossOrigin="";
			imageSource.onload=onload;
			imageSource.onerror=onerror;
			imageSource.src=url;
			image=imageSource;
			Loader._imgCache[url]=imageSource;
		}
	}

	/**
	*@private
	*加载声音资源。
	*@param url 资源地址。
	*/
	__proto._loadSound=function(url){
		var sound=(new SoundManager._soundClass());
		var _this=this;
		sound.on("complete",this,soundOnload);
		sound.on("error",this,soundOnErr);
		sound.load(url);
		function soundOnload (){
			clear();
			_this.onLoaded(sound);
		}
		function soundOnErr (){
			clear();
			sound.dispose();
			_this.event("error","Load sound failed");
		}
		function clear (){
			sound.offAll();
		}
	}

	/**@private */
	__proto.onProgress=function(value){
		if (this._type==="atlas")this.event("progress",value *0.3);
		else this.event("progress",value);
	}

	/**@private */
	__proto.onError=function(message){
		this.event("error",message);
	}

	/**
	*资源加载完成的处理函数。
	*@param data 数据。
	*/
	__proto.onLoaded=function(data){
		var type=this._type;
		if (type=="plf"){
			this.parsePLFData(data);
			this.complete(data);
			}else if (type==="image"){
			var tex=new Texture(data);
			tex.url=this._url;
			this.complete(tex);
			}else if (type==="sound" || type==="htmlimage" || type==="nativeimage"){
			this.complete(data);
			}else if (type==="atlas"){
			if (!data.url && !data._setContext){
				if (!this._data){
					this._data=data;
					if (data.meta && data.meta.image){
						var toloadPics=data.meta.image.split(",");
						var split=this._url.indexOf("/")>=0 ? "/" :"\\";
						var idx=this._url.lastIndexOf(split);
						var folderPath=idx >=0 ? this._url.substr(0,idx+1):"";
						for (var i=0,len=toloadPics.length;i < len;i++){
							toloadPics[i]=folderPath+toloadPics[i];
						}
						}else {
						toloadPics=[this._url.replace(".json",".png")];
					}
					toloadPics.reverse();
					data.toLoads=toloadPics;
					data.pics=[];
				}
				this.event("progress",0.3+1 / toloadPics.length *0.6);
				return this._loadImage(toloadPics.pop());
				}else {
				this._data.pics.push(data);
				if (this._data.toLoads.length > 0){
					this.event("progress",0.3+1 / this._data.toLoads.length *0.6);
					return this._loadImage(this._data.toLoads.pop());
				};
				var frames=this._data.frames;
				var cleanUrl=this._url.split("?")[0];
				var directory=(this._data.meta && this._data.meta.prefix)? this._data.meta.prefix :cleanUrl.substring(0,cleanUrl.lastIndexOf("."))+"/";
				var pics=this._data.pics;
				var atlasURL=URL.formatURL(this._url);
				var map=Loader.atlasMap[atlasURL] || (Loader.atlasMap[atlasURL]=[]);
				map.dir=directory;
				var scaleRate=1;
				if (this._data.meta && this._data.meta.scale && this._data.meta.scale !=1){
					scaleRate=parseFloat(this._data.meta.scale);
					for (var name in frames){
						var obj=frames[name];
						var tPic=pics[obj.frame.idx ? obj.frame.idx :0];
						var url=URL.formatURL(directory+name);
						tPic.scaleRate=scaleRate;
						var tTexture;
						tTexture=Texture._create(tPic,obj.frame.x,obj.frame.y,obj.frame.w,obj.frame.h,obj.spriteSourceSize.x,obj.spriteSourceSize.y,obj.sourceSize.w,obj.sourceSize.h,laya.net.Loader.getRes(url));
						Loader.cacheRes(url,tTexture);
						tTexture.url=url;
						map.push(url);
					}
					}else {
					for (name in frames){
						obj=frames[name];
						tPic=pics[obj.frame.idx ? obj.frame.idx :0];
						url=URL.formatURL(directory+name);
						tTexture=Texture._create(tPic,obj.frame.x,obj.frame.y,obj.frame.w,obj.frame.h,obj.spriteSourceSize.x,obj.spriteSourceSize.y,obj.sourceSize.w,obj.sourceSize.h,laya.net.Loader.getRes(url));
						Loader.cacheRes(url,tTexture);
						tTexture.url=url;
						map.push(url);
					}
				}
				delete this._data.pics;
				this.complete(this._data);
			}
			}else if (type==="font"){
			if (!data._source){
				this._data=data;
				this.event("progress",0.5);
				return this._loadImage(this._url.replace(".fnt",".png"));
				}else {
				var bFont=new BitmapFont();
				bFont.parseFont(this._data,new Texture(data));
				var tArr=this._url.split(".fnt")[0].split("/");
				var fontName=tArr[tArr.length-1];
				Text.registerBitmapFont(fontName,bFont);
				this._data=bFont;
				this.complete(this._data);
			}
			}else if (type==="prefab"){
			var prefab=new Prefab();
			prefab.json=data;
			this.complete(prefab);
			}else {
			this.complete(data);
		}
	}

	__proto.parsePLFData=function(plfData){
		var type;
		var filePath;
		var fileDic;
		for (type in plfData){
			fileDic=plfData[type];
			switch (type){
				case "json":
				case "text":
					for (filePath in fileDic){
						Loader.preLoadedMap[URL.formatURL(filePath)]=fileDic[filePath]
					}
					break ;
				default :
					for (filePath in fileDic){
						Loader.preLoadedMap[URL.formatURL(filePath)]=fileDic[filePath]
					}
				}
		}
	}

	/**
	*加载完成。
	*@param data 加载的数据。
	*/
	__proto.complete=function(data){
		this._data=data;
		if (this._customParse){
			this.event("loaded",(data instanceof Array)? [data] :data);
			}else {
			Loader._loaders.push(this);
			if (!Loader._isWorking)Loader.checkNext();
		}
	}

	/**
	*结束加载，处理是否缓存及派发完成事件 <code>Event.COMPLETE</code> 。
	*@param content 加载后的数据
	*/
	__proto.endLoad=function(content){
		content && (this._data=content);
		if (this._cache)Loader.cacheRes(this._url,this._data);
		this.event("progress",1);
		this.event("complete",(this.data instanceof Array)? [this.data] :this.data);
	}

	/**加载地址。*/
	__getset(0,__proto,'url',function(){
		return this._url;
	});

	/**返回的数据。*/
	__getset(0,__proto,'data',function(){
		return this._data;
	});

	/**是否缓存。*/
	__getset(0,__proto,'cache',function(){
		return this._cache;
	});

	/**加载类型。*/
	__getset(0,__proto,'type',function(){
		return this._type;
	});

	Loader.getTypeFromUrl=function(url){
		var type=Utils.getFileExtension(url);
		if (type)return Loader.typeMap[type];
		console.warn("Not recognize the resources suffix",url);
		return "text";
	}

	Loader.checkNext=function(){
		Loader._isWorking=true;
		var startTimer=Browser.now();
		var thisTimer=startTimer;
		while (Loader._startIndex < Loader._loaders.length){
			thisTimer=Browser.now();
			Loader._loaders[Loader._startIndex].endLoad();
			Loader._startIndex++;
			if (Browser.now()-startTimer > Loader.maxTimeOut){
				console.warn("loader callback cost a long time:"+(Browser.now()-startTimer)+" url="+Loader._loaders[Loader._startIndex-1].url);
				Laya.systemTimer.frameOnce(1,null,Loader.checkNext);
				return;
			}
		}
		Loader._loaders.length=0;
		Loader._startIndex=0;
		Loader._isWorking=false;
	}

	Loader.clearRes=function(url){
		url=URL.formatURL(url);
		var arr=Loader.getAtlas(url);
		if (arr){
			for (var i=0,n=arr.length;i < n;i++){
				var resUrl=arr[i];
				var tex=Loader.getRes(resUrl);
				delete Loader.loadedMap[resUrl];
				if (tex)tex.destroy();
			}
			arr.length=0;
			delete Loader.atlasMap[url];
			delete Loader.loadedMap[url];
			}else {
			var res=Loader.loadedMap[url];
			if (res){
				delete Loader.loadedMap[url];
				if ((res instanceof laya.resource.Texture )&& res.bitmap)(res).destroy();
			}
		}
	}

	Loader.clearTextureRes=function(url){
		url=URL.formatURL(url);
		var arr=laya.net.Loader.getAtlas(url);
		var res=(arr && arr.length > 0)? laya.net.Loader.getRes(arr[0]):laya.net.Loader.getRes(url);
		if ((res instanceof laya.resource.Texture ))
			res.disposeBitmap();
	}

	Loader.getRes=function(url){
		return Loader.loadedMap[URL.formatURL(url)];
	}

	Loader.getAtlas=function(url){
		return Loader.atlasMap[URL.formatURL(url)];
	}

	Loader.cacheRes=function(url,data){
		url=URL.formatURL(url);
		if (Loader.loadedMap[url] !=null){
			console.warn("Resources already exist,is repeated loading:",url);
			}else {
			Loader.loadedMap[url]=data;
		}
	}

	Loader.setGroup=function(url,group){
		if (!Loader.groupMap[group])Loader.groupMap[group]=[];
		Loader.groupMap[group].push(url);
	}

	Loader.clearResByGroup=function(group){
		if (!Loader.groupMap[group])return;
		var arr=Loader.groupMap[group],i=0,len=arr.length;
		for (i=0;i < len;i++){
			Loader.clearRes(arr[i]);
		}
		arr.length=0;
	}

	Loader.TEXT="text";
	Loader.JSON="json";
	Loader.PREFAB="prefab";
	Loader.XML="xml";
	Loader.BUFFER="arraybuffer";
	Loader.IMAGE="image";
	Loader.SOUND="sound";
	Loader.ATLAS="atlas";
	Loader.FONT="font";
	Loader.TTF="ttf";
	Loader.PLF="plf";
	Loader.HIERARCHY="HIERARCHY";
	Loader.MESH="MESH";
	Loader.MATERIAL="MATERIAL";
	Loader.TEXTURE2D="TEXTURE2D";
	Loader.TEXTURECUBE="TEXTURECUBE";
	Loader.ANIMATIONCLIP="ANIMATIONCLIP";
	Loader.AVATAR="AVATAR";
	Loader.TERRAINHEIGHTDATA="TERRAINHEIGHTDATA";
	Loader.TERRAINRES="TERRAIN";
	Loader.typeMap={"ttf":"ttf","png":"image","jpg":"image","jpeg":"image","txt":"text","json":"json","prefab":"prefab","xml":"xml","als":"atlas","atlas":"atlas","mp3":"sound","ogg":"sound","wav":"sound","part":"json","fnt":"font","pkm":"pkm","plf":"plf","scene":"json","ani":"json","sk":"arraybuffer"};
	Loader.parserMap={};
	Loader.maxTimeOut=100;
	Loader.groupMap={};
	Loader.loadedMap={};
	Loader.atlasMap={};
	Loader.preLoadedMap={};
	Loader._imgCache={};
	Loader._loaders=[];
	Loader._isWorking=false;
	Loader._startIndex=0;
	return Loader;
})(EventDispatcher)


//class laya.net.SceneLoader extends laya.events.EventDispatcher
var SceneLoader=(function(_super){
	function SceneLoader(){
		this.totalCount=0;
		this._completeHandler=null;
		this._toLoadList=null;
		this._isLoading=false;
		this._curUrl=null;
		SceneLoader.__super.call(this);
		this._completeHandler=new Handler(this,this.onOneLoadComplete);
		this.reset();
	}

	__class(SceneLoader,'laya.net.SceneLoader',_super);
	var __proto=SceneLoader.prototype;
	__proto.reset=function(){
		this._toLoadList=[];
		this._isLoading=false;
		this.totalCount=0;
	}

	__proto.load=function(url,is3D,ifCheck){
		(is3D===void 0)&& (is3D=false);
		(ifCheck===void 0)&& (ifCheck=true);
		if ((url instanceof Array)){
			var i=0,len=0;
			len=url.length;
			for (i=0;i < len;i++){
				this._addToLoadList(url[i],is3D);
			}
			}else {
			this._addToLoadList(url,is3D);
		}
		if(ifCheck)
			this._checkNext();
	}

	__proto._addToLoadList=function(url,is3D){
		(is3D===void 0)&& (is3D=false);
		if (this._toLoadList.indexOf(url)>=0)return;
		if (Loader.getRes(url))return;
		if (is3D){
			this._toLoadList.push({url:url});
		}else
		this._toLoadList.push(url);
		this.totalCount++;
	}

	__proto._checkNext=function(){
		if (!this._isLoading){
			if (this._toLoadList.length==0){
				this.event("complete");
				return;
			};
			var tItem;
			tItem=this._toLoadList.pop();
			if ((typeof tItem=='string')){
				this.loadOne(tItem);
				}else{
				this.loadOne(tItem.url,true);
			}
		}
	}

	__proto.loadOne=function(url,is3D){
		(is3D===void 0)&& (is3D=false);
		this._curUrl=url;
		var type=Utils.getFileExtension(this._curUrl);
		if (is3D){
			Laya.loader.create(url,this._completeHandler);
		}else
		if (SceneLoader.LoadableExtensions[type]){
			Laya.loader.load(url,this._completeHandler,null,SceneLoader.LoadableExtensions[type]);
			}else if (url !=AtlasInfoManager.getFileLoadPath(url)|| SceneLoader.No3dLoadTypes[type] || !LoaderManager.createMap[type]){
			Laya.loader.load(url,this._completeHandler);
			}else {
			Laya.loader.create(url,this._completeHandler);
		}
	}

	__proto.onOneLoadComplete=function(){
		this._isLoading=false;
		if (!Loader.getRes(this._curUrl)){
			console.log("Fail to load:",this._curUrl);
		}
		this.event("progress");
		var type=Utils.getFileExtension(this._curUrl);
		if (SceneLoader.LoadableExtensions[type]){
			var dataO;
			dataO=Loader.getRes(this._curUrl);
			if (dataO&&((dataO instanceof laya.components.Prefab ))){
				dataO=dataO.json;
			}
			if (dataO){
				if (dataO.loadList){
					this.load(dataO.loadList,false,false);
				}
				if (dataO.loadList3D){
					this.load(dataO.loadList3D,true,false);
				}
			}
		}
		this._checkNext();
	}

	__getset(0,__proto,'loadedCount',function(){
		return this.totalCount-this.leftCount;
	});

	__getset(0,__proto,'leftCount',function(){
		if (this._isLoading)return this._toLoadList.length+1;
		return this._toLoadList.length;
	});

	__static(SceneLoader,
	['LoadableExtensions',function(){return this.LoadableExtensions={"scene":"json","scene3d":"json","ani":"json","ui":"json","prefab":"prefab"};},'No3dLoadTypes',function(){return this.No3dLoadTypes={"png":true,"jpg":true,"txt":true};}
	]);
	return SceneLoader;
})(EventDispatcher)


//class laya.net.WorkerLoader extends laya.events.EventDispatcher
var WorkerLoader=(function(_super){
	function WorkerLoader(){
		/**使用的Worker对象。*/
		this.worker=null;
		/**@private */
		this._useWorkerLoader=false;
		WorkerLoader.__super.call(this);
		var _$this=this;
		this.worker=new Browser.window.Worker(WorkerLoader.workerPath);
		this.worker.onmessage=function (evt){
			_$this.workerMessage(evt.data);
		}
	}

	__class(WorkerLoader,'laya.net.WorkerLoader',_super);
	var __proto=WorkerLoader.prototype;
	/**
	*@private
	*/
	__proto.workerMessage=function(data){
		if (data){
			switch (data.type){
				case "Image":
					this.imageLoaded(data);
					break ;
				case "Disable":
					WorkerLoader.enable=false;
					break ;
				}
		}
	}

	/**
	*@private
	*/
	__proto.imageLoaded=function(data){
		if (!data.dataType || data.dataType !="imageBitmap"){
			this.event(data.url,null);
			return;
		};
		var canvas=new HTMLCanvas(true);
		var ctx=canvas.source.getContext("2d");
		switch (data.dataType){
			case "imageBitmap":;
				var imageData=data.imageBitmap;
				canvas.size(imageData.width,imageData.height);
				ctx.drawImage(imageData,0,0);
				break ;
			}
		console.log("load:",data.url);
		if (Render.isWebGL){
			canvas._setGPUMemory(0);
			var tex=new laya.webgl.resource.Texture2D();;
			tex.loadImageSource(canvas);
			canvas=tex;
		}
		this.event(data.url,canvas);
	}

	/**
	*加载图片
	*@param url 图片地址
	*/
	__proto.loadImage=function(url){
		this.worker.postMessage(url);
	}

	/**
	*@private
	*加载图片资源。
	*@param url 资源地址。
	*/
	__proto._loadImage=function(url){
		var _this=this;
		if (!this._useWorkerLoader || !WorkerLoader._enable){
			WorkerLoader._preLoadFun.call(_this,url);
			return;
		}
		url=URL.formatURL(url);
		function clear (){
			laya.net.WorkerLoader.I.off(url,_this,onload);
		};
		var onload=function (image){
			clear();
			if (image){
				_this["onLoaded"](image);
				}else {
				WorkerLoader._preLoadFun.call(_this,url);
			}
		};
		laya.net.WorkerLoader.I.on(url,_this,onload);
		laya.net.WorkerLoader.I.loadImage(url);
	}

	/**
	*是否启用。
	*/
	__getset(1,WorkerLoader,'enable',function(){
		return WorkerLoader._enable;
		},function(value){
		if (WorkerLoader._enable !=value){
			WorkerLoader._enable=value;
			if (value && WorkerLoader._preLoadFun==null)WorkerLoader._enable=WorkerLoader.__init__();
		}
	});

	WorkerLoader.__init__=function(){
		if (WorkerLoader._preLoadFun !=null)return false;
		if (!Browser.window.Worker)return false;
		WorkerLoader._preLoadFun=Loader["prototype"]["_loadImage"];
		Loader["prototype"]["_loadImage"]=WorkerLoader["prototype"]["_loadImage"];
		if (!WorkerLoader.I)WorkerLoader.I=new WorkerLoader();
		return true;
	}

	WorkerLoader.workerSupported=function(){
		return Browser.window.Worker ? true :false;
	}

	WorkerLoader.enableWorkerLoader=function(){
		if (!WorkerLoader._tryEnabled){
			WorkerLoader.enable=true;
			WorkerLoader._tryEnabled=true;
		}
	}

	WorkerLoader.I=null;
	WorkerLoader.workerPath="libs/workerloader.js";
	WorkerLoader._preLoadFun=null;
	WorkerLoader._enable=false;
	WorkerLoader._tryEnabled=false;
	return WorkerLoader;
})(EventDispatcher)


//class laya.resource.Texture extends laya.events.EventDispatcher
var Texture=(function(_super){
	function Texture(bitmap,uv,sourceWidth,sourceHeight){
		/**@private uv的范围*/
		this.uvrect=[0,0,1,1];
		/**@private */
		this._w=0;
		/**@private */
		this._h=0;
		/**@private */
		this._destroyed=false;
		/**@private */
		//this._bitmap=null;
		/**@private */
		//this._uv=null;
		/**@private */
		this._referenceCount=0;
		/**@private [NATIVE]*/
		//this._nativeObj=null;
		/**@private 唯一ID*/
		//this.$_GID=NaN;
		/**沿 X 轴偏移量。*/
		this.offsetX=0;
		/**沿 Y 轴偏移量。*/
		this.offsetY=0;
		/**原始宽度（包括被裁剪的透明区域）。*/
		this.sourceWidth=0;
		/**原始高度（包括被裁剪的透明区域）。*/
		this.sourceHeight=0;
		/**图片地址*/
		//this.url=null;
		/**@private */
		this.scaleRate=1;
		Texture.__super.call(this);
		(sourceWidth===void 0)&& (sourceWidth=0);
		(sourceHeight===void 0)&& (sourceHeight=0);
		this.setTo(bitmap,uv,sourceWidth,sourceHeight);
	}

	__class(Texture,'laya.resource.Texture',_super);
	var __proto=Texture.prototype;
	/**
	*@private
	*/
	__proto._addReference=function(){
		this._bitmap && this._bitmap._addReference();
		this._referenceCount++;
	}

	/**
	*@private
	*/
	__proto._removeReference=function(){
		this._bitmap && this._bitmap._removeReference();
		this._referenceCount--;
	}

	/**
	*@private
	*/
	__proto._getSource=function(){
		if (this._destroyed || !this._bitmap)
			return null;
		this.recoverBitmap();
		return this._bitmap.destroyed ? null :this.bitmap._getSource();
	}

	/**
	*@private
	*/
	__proto._onLoaded=function(complete,context){
		if (!context){
			}else if (context==this){
			}else if ((context instanceof laya.resource.Texture )){
			var tex=context;
			Texture._create(context,0,0,tex.width,tex.height,0,0,tex.sourceWidth,tex.sourceHeight,this);
			}else {
			this.bitmap=context;
			this.sourceWidth=this._w=context.width;
			this.sourceHeight=this._h=context.height;
		}
		complete && complete.run();
		this.event("ready",this);
	}

	/**
	*获取是否可以使用。
	*/
	__proto.getIsReady=function(){
		return this._destroyed ? false :(this._bitmap ? true :false);
	}

	/**
	*设置此对象的位图资源、UV数据信息。
	*@param bitmap 位图资源
	*@param uv UV数据信息
	*/
	__proto.setTo=function(bitmap,uv,sourceWidth,sourceHeight){
		(sourceWidth===void 0)&& (sourceWidth=0);
		(sourceHeight===void 0)&& (sourceHeight=0);
		this.bitmap=bitmap;
		this.sourceWidth=sourceWidth;
		this.sourceHeight=sourceHeight;
		if (bitmap){
			this._w=bitmap.width;
			this._h=bitmap.height;
			this.sourceWidth=this.sourceWidth || this._w;
			this.sourceHeight=this.sourceHeight || this._h;
			var _this=this;
		}
		this.uv=uv || Texture.DEF_UV;
	}

	/**
	*加载指定地址的图片。
	*@param url 图片地址。
	*@param complete 加载完成回调
	*/
	__proto.load=function(url,complete){
		if (!this._destroyed)
			Laya.loader.load(url,Handler.create(this,this._onLoaded,[complete]),null,"htmlimage",1,false,null,true);
	}

	/**
	*获取Texture上的某个区域的像素点
	*@param x
	*@param y
	*@param width
	*@param height
	*@return 返回像素点集合
	*/
	__proto.getPixels=function(x,y,width,height){
		if (Render.isWebGL){
			return RunDriver.getTexturePixels(this,x,y,width,height);
			}else if (Render.isConchApp){
			return this._nativeObj.getImageData(0,0,width,height);
			}else {
			Browser.canvas.size(width,height);
			Browser.canvas.clear();
			Browser.context.drawImage(this,-x,-y,this.width,this.height,0,0);
			var info=Browser.context.getImageData(0,0,width,height);
			return info.data;
		}
	}

	/**
	*通过url强制恢复bitmap。
	*/
	__proto.recoverBitmap=function(){
		if (!this._destroyed && (!this._bitmap || this._bitmap.destroyed)&& this.url)
			this.load(this.url);
	}

	/**
	*强制释放Bitmap,无论是否被引用。
	*/
	__proto.disposeBitmap=function(){
		if (!this._destroyed && this._bitmap){
			this._bitmap.destroy();
		}
	}

	/**
	*销毁纹理。
	*/
	__proto.destroy=function(){
		if (!this._destroyed){
			this._destroyed=true;
			if (this.bitmap){
				this.bitmap._removeReference(this._referenceCount);
				this.bitmap=null;
			}
			if (this.url && this===Laya.loader.getRes(this.url))
				Laya.loader.clearRes(this.url);
		}
	}

	/**实际高度。*/
	__getset(0,__proto,'height',function(){
		if (this._h)
			return this._h;
		if (!this.bitmap)return 0;
		return (this.uv && this.uv!==Texture.DEF_UV)? (this.uv[5]-this.uv[1])*this.bitmap.height :this.bitmap.height;
		},function(value){
		this._h=value;
		this.sourceHeight || (this.sourceHeight=value);
	});

	__getset(0,__proto,'uv',function(){
		return this._uv;
		},function(value){
		this.uvrect[0]=Math.min(value[0],value[2],value[4],value[6]);
		this.uvrect[1]=Math.min(value[1],value[3],value[5],value[7]);
		this.uvrect[2]=Math.max(value[0],value[2],value[4],value[6])-this.uvrect[0];
		this.uvrect[3]=Math.max(value[1],value[3],value[5],value[7])-this.uvrect[1];
		this._uv=value;
	});

	/**实际宽度。*/
	__getset(0,__proto,'width',function(){
		if (this._w)
			return this._w;
		if (!this.bitmap)return 0;
		return (this.uv && this.uv!==Texture.DEF_UV)? (this.uv[2]-this.uv[0])*this.bitmap.width :this.bitmap.width;
		},function(value){
		this._w=value;
		this.sourceWidth || (this.sourceWidth=value);
	});

	/**
	*设置位图。
	*@param 位图。
	*/
	/**
	*获取位图。
	*@return 位图。
	*/
	__getset(0,__proto,'bitmap',function(){
		return this._bitmap;
		},function(value){
		this._bitmap && this._bitmap._removeReference(this._referenceCount);
		this._bitmap=value;
		value && (value._addReference(this._referenceCount));
	});

	/**
	*获取是否已经销毁。
	*@return 是否已经销毁。
	*/
	__getset(0,__proto,'destroyed',function(){
		return this._destroyed;
	});

	Texture.moveUV=function(offsetX,offsetY,uv){
		for (var i=0;i < 8;i+=2){
			uv[i]+=offsetX;
			uv[i+1]+=offsetY;
		}
		return uv;
	}

	Texture.create=function(source,x,y,width,height,offsetX,offsetY,sourceWidth,sourceHeight){
		(offsetX===void 0)&& (offsetX=0);
		(offsetY===void 0)&& (offsetY=0);
		(sourceWidth===void 0)&& (sourceWidth=0);
		(sourceHeight===void 0)&& (sourceHeight=0);
		return Texture._create(source,x,y,width,height,offsetX,offsetY,sourceWidth,sourceHeight);
	}

	Texture._create=function(source,x,y,width,height,offsetX,offsetY,sourceWidth,sourceHeight,outTexture){
		(offsetX===void 0)&& (offsetX=0);
		(offsetY===void 0)&& (offsetY=0);
		(sourceWidth===void 0)&& (sourceWidth=0);
		(sourceHeight===void 0)&& (sourceHeight=0);
		var btex=(source instanceof laya.resource.Texture );
		var uv=btex ? source.uv :Texture.DEF_UV;
		var bitmap=btex ? source.bitmap :source;
		if (bitmap.width && (x+width)> bitmap.width)
			width=bitmap.width-x;
		if (bitmap.height && (y+height)> bitmap.height)
			height=bitmap.height-y;
		var tex;
		if (outTexture){
			tex=outTexture;
			tex.setTo(bitmap,null,sourceWidth || width,sourceHeight || height);
			}else {
			tex=new Texture(bitmap,null,sourceWidth || width,sourceHeight || height)
		}
		tex.width=width;
		tex.height=height;
		tex.offsetX=offsetX;
		tex.offsetY=offsetY;
		var dwidth=1 / bitmap.width;
		var dheight=1 / bitmap.height;
		x *=dwidth;
		y *=dheight;
		width *=dwidth;
		height *=dheight;
		var u1=tex.uv[0],v1=tex.uv[1],u2=tex.uv[4],v2=tex.uv[5];
		var inAltasUVWidth=(u2-u1),inAltasUVHeight=(v2-v1);
		var oriUV=Texture.moveUV(uv[0],uv[1],[x,y,x+width,y,x+width,y+height,x,y+height]);
		tex.uv=[u1+oriUV[0] *inAltasUVWidth,v1+oriUV[1] *inAltasUVHeight,u2-(1-oriUV[2])*inAltasUVWidth,v1+oriUV[3] *inAltasUVHeight,u2-(1-oriUV[4])*inAltasUVWidth,v2-(1-oriUV[5])*inAltasUVHeight,u1+oriUV[6] *inAltasUVWidth,v2-(1-oriUV[7])*inAltasUVHeight];
		var bitmapScale=bitmap.scaleRate;
		if (bitmapScale && bitmapScale !=1){
			tex.sourceWidth /=bitmapScale;
			tex.sourceHeight /=bitmapScale;
			tex.width /=bitmapScale;
			tex.height /=bitmapScale;
			tex.scaleRate=bitmapScale;
			}else {
			tex.scaleRate=1;
		}
		return tex;
	}

	Texture.createFromTexture=function(texture,x,y,width,height){
		var texScaleRate=texture.scaleRate;
		if (texScaleRate !=1){
			x *=texScaleRate;
			y *=texScaleRate;
			width *=texScaleRate;
			height *=texScaleRate;
		};
		var rect=Rectangle.TEMP.setTo(x-texture.offsetX,y-texture.offsetY,width,height);
		var result=rect.intersection(Texture._rect1.setTo(0,0,texture.width,texture.height),Texture._rect2);
		if (result)
			var tex=Texture.create(texture,result.x,result.y,result.width,result.height,result.x-rect.x,result.y-rect.y,width,height);
		else
		return null;
		return tex;
	}

	Texture.DEF_UV=[0,0,1.0,0,1.0,1.0,0,1.0];
	Texture.NO_UV=[0,0,0,0,0,0,0,0];
	Texture.INV_UV=[0,1,1.0,1,1.0,0.0,0,0.0];
	Texture._rect1=new Rectangle();
	Texture._rect2=new Rectangle();
	return Texture;
})(EventDispatcher)


//class laya.ui.AutoBitmap extends laya.display.Graphics
var AutoBitmap=(function(_super){
	function AutoBitmap(){
		/**@private 是否自动缓存命令*/
		this.autoCacheCmd=true;
		/**@private 宽度*/
		this._width=0;
		/**@private 高度*/
		this._height=0;
		/**@private 源数据*/
		this._source=null;
		/**@private 网格数据*/
		this._sizeGrid=null;
		/**@private */
		this._isChanged=false;
		/**@private */
		this._offset=null;
		AutoBitmap.__super.call(this);
	}

	__class(AutoBitmap,'laya.ui.AutoBitmap',_super);
	var __proto=AutoBitmap.prototype;
	/**@inheritDoc */
	__proto.destroy=function(){
		_super.prototype.destroy.call(this);
		this._source=null;
		this._sizeGrid=null;
		this._offset=null;
	}

	/**@private */
	__proto._setChanged=function(){
		if (!this._isChanged){
			this._isChanged=true;
			Laya.timer.callLater(this,this.changeSource);
		}
	}

	/**
	*@private
	*修改纹理资源。
	*/
	__proto.changeSource=function(){
		this._isChanged=false;
		var source=this._source;
		if (!source || !source.bitmap)return;
		var width=this.width;
		var height=this.height;
		var sizeGrid=this._sizeGrid;
		var sw=source.sourceWidth;
		var sh=source.sourceHeight;
		if (!sizeGrid || (sw===width && sh===height)){
			this.clear();
			this.drawTexture(source,this._offset ? this._offset[0] :0,this._offset ? this._offset[1] :0,width,height);
			}else {
			this.clear();
			var top=sizeGrid[0];
			var right=sizeGrid[1];
			var bottom=sizeGrid[2];
			var left=sizeGrid[3];
			var repeat=sizeGrid[4];
			var needClip=false;
			if (width==sw){
				left=right=0;
			}
			if (height==sh){
				top=bottom=0;
			}
			if (left+right > width){
				var clipWidth=width;
				needClip=true;
				width=left+right;
				this.save();
				this.clipRect(0,0,clipWidth,height);
			}
			left && top && this.drawImage(AutoBitmap.getTexture(source,0,0,left,top),0,0,left,top);
			right && top && this.drawImage(AutoBitmap.getTexture(source,sw-right,0,right,top),width-right,0,right,top);
			left && bottom && this.drawImage(AutoBitmap.getTexture(source,0,sh-bottom,left,bottom),0,height-bottom,left,bottom);
			right && bottom && this.drawImage(AutoBitmap.getTexture(source,sw-right,sh-bottom,right,bottom),width-right,height-bottom,right,bottom);
			top && this.drawBitmap(repeat,AutoBitmap.getTexture(source,left,0,sw-left-right,top),left,0,width-left-right,top);
			bottom && this.drawBitmap(repeat,AutoBitmap.getTexture(source,left,sh-bottom,sw-left-right,bottom),left,height-bottom,width-left-right,bottom);
			left && this.drawBitmap(repeat,AutoBitmap.getTexture(source,0,top,left,sh-top-bottom),0,top,left,height-top-bottom);
			right && this.drawBitmap(repeat,AutoBitmap.getTexture(source,sw-right,top,right,sh-top-bottom),width-right,top,right,height-top-bottom);
			this.drawBitmap(repeat,AutoBitmap.getTexture(source,left,top,sw-left-right,sh-top-bottom),left,top,width-left-right,height-top-bottom);
			if (needClip)this.restore();
		}
		this._repaint();
	}

	__proto.drawBitmap=function(repeat,tex,x,y,width,height){
		(width===void 0)&& (width=0);
		(height===void 0)&& (height=0);
		if (width < 0.1 || height < 0.1)return;
		if (repeat && (tex.width !=width || tex.height !=height))this.fillTexture(tex,x,y,width,height);
		else this.drawImage(tex,x,y,width,height);
	}

	/**
	*当前实例的有效缩放网格数据。
	*<p>如果设置为null,则在应用任何缩放转换时，将正常缩放整个显示对象。</p>
	*<p>数据格式：[上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)]。
	*<ul><li>例如：[4,4,4,4,1]</li></ul></p>
	*<p> <code>sizeGrid</code> 的值如下所示：
	*<ol>
	*<li>上边距</li>
	*<li>右边距</li>
	*<li>下边距</li>
	*<li>左边距</li>
	*<li>是否重复填充(值为0：不重复填充，1：重复填充)</li>
	*</ol></p>
	*<p>当定义 <code>sizeGrid</code> 属性时，该显示对象被分割到以 <code>sizeGrid</code> 数据中的"上边距,右边距,下边距,左边距" 组成的矩形为基础的具有九个区域的网格中，该矩形定义网格的中心区域。网格的其它八个区域如下所示：
	*<ul>
	*<li>矩形上方的区域</li>
	*<li>矩形外的右上角</li>
	*<li>矩形左侧的区域</li>
	*<li>矩形右侧的区域</li>
	*<li>矩形外的左下角</li>
	*<li>矩形下方的区域</li>
	*<li>矩形外的右下角</li>
	*<li>矩形外的左上角</li>
	*</ul>
	*同时也支持3宫格，比如0,4,0,4,1为水平3宫格，4,0,4,0,1为垂直3宫格，3宫格性能比9宫格高。
	*</p>
	*/
	__getset(0,__proto,'sizeGrid',function(){
		return this._sizeGrid;
		},function(value){
		this._sizeGrid=value;
		this._setChanged();
	});

	/**
	*表示显示对象的宽度，以像素为单位。
	*/
	__getset(0,__proto,'width',function(){
		if (this._width)return this._width;
		if (this._source)return this._source.sourceWidth;
		return 0;
		},function(value){
		if (this._width !=value){
			this._width=value;
			this._setChanged();
		}
	});

	/**
	*表示显示对象的高度，以像素为单位。
	*/
	__getset(0,__proto,'height',function(){
		if (this._height)return this._height;
		if (this._source)return this._source.sourceHeight;
		return 0;
		},function(value){
		if (this._height !=value){
			this._height=value;
			this._setChanged();
		}
	});

	/**
	*对象的纹理资源。
	*@see laya.resource.Texture
	*/
	__getset(0,__proto,'source',function(){
		return this._source;
		},function(value){
		if (value){
			this._source=value
			this._setChanged();
			}else {
			this._source=null;
			this.clear();
		}
	});

	AutoBitmap.getTexture=function(tex,x,y,width,height){
		if (width <=0)width=1;
		if (height <=0)height=1;
		tex.$_GID || (tex.$_GID=Utils.getGID())
		var texture;
		if (!texture || !texture._getSource()){
			texture=Texture.createFromTexture(tex,x,y,width,height);
		}
		return texture;
	}

	return AutoBitmap;
})(Graphics)


//class laya.ui.Widget extends laya.components.Component
var Widget=(function(_super){
	function Widget(){
		Widget.__super.call(this);
		this._top=NaN;
		this._bottom=NaN;
		this._left=NaN;
		this._right=NaN;
		this._centerX=NaN;
		this._centerY=NaN;
	}

	__class(Widget,'laya.ui.Widget',_super);
	var __proto=Widget.prototype;
	__proto.onReset=function(){
		this._top=this._bottom=this._left=this._right=this._centerX=this._centerY=NaN;
	}

	__proto._onEnable=function(){
		if (this.owner.parent)this._onAdded();
		else this.owner.once("added",this,this._onAdded);
	}

	__proto._onDisable=function(){
		this.owner.off("added",this,this._onAdded);
		if (this.owner.parent)this.owner.parent.off("resize",this,this._onParentResize);
	}

	/**
	*对象被添加到显示列表的事件侦听处理函数。
	*/
	__proto._onAdded=function(){
		if (this.owner.parent)
			this.owner.parent.on("resize",this,this._onParentResize);
		this.resetLayoutX();
		this.resetLayoutY();
	}

	/**
	*父容器的 <code>Event.RESIZE</code> 事件侦听处理函数。
	*/
	__proto._onParentResize=function(){
		this.resetLayoutX();
		this.resetLayoutY();
		this.owner.event("resize");
	}

	/**
	*<p>重置对象的 <code>X</code> 轴（水平方向）布局。</p>
	*@private
	*/
	__proto.resetLayoutX=function(){
		var owner=this.owner;
		if (!owner)return;
		var parent=owner.parent;
		if (parent){
			if (!isNaN(this.centerX)){
				owner.x=Math.round((parent.width-owner.displayWidth)*0.5+this.centerX+owner.pivotX *owner.scaleX);
				}else if (!isNaN(this.left)){
				owner.x=Math.round(this.left+owner.pivotX *owner.scaleX);
				if (!isNaN(this.right)){
					owner.width=(parent._width-this.left-this.right)/ (owner.scaleX || 0.01);
				}
				}else if (!isNaN(this.right)){
				owner.x=Math.round(parent.width-owner.displayWidth-this.right+owner.pivotX *owner.scaleX);
			}
		}
	}

	/**
	*<p>重置对象的 <code>Y</code> 轴（垂直方向）布局。</p>
	*@private
	*/
	__proto.resetLayoutY=function(){
		var owner=this.owner;
		if (!owner)return;
		var parent=owner.parent;
		if (parent){
			if (!isNaN(this.centerY)){
				owner.y=Math.round((parent.height-owner.displayHeight)*0.5+this.centerY+owner.pivotY *owner.scaleY);
				}else if (!isNaN(this.top)){
				owner.y=Math.round(this.top+owner.pivotY *owner.scaleY);
				if (!isNaN(this.bottom)){
					owner.height=(parent._height-this.top-this.bottom)/ (owner.scaleY || 0.01);
				}
				}else if (!isNaN(this.bottom)){
				owner.y=Math.round(parent.height-owner.displayHeight-this.bottom+owner.pivotY *owner.scaleY);
			}
		}
	}

	/**
	*重新计算布局
	*/
	__proto.resetLayout=function(){
		if (this.owner){
			this.resetLayoutX();
			this.resetLayoutY();
		}
	}

	/**表示距水平方向中心轴的距离（以像素为单位）。*/
	__getset(0,__proto,'centerX',function(){
		return this._centerX;
		},function(value){
		if (this._centerX !=value){
			this._centerX=value;
			this.resetLayoutX();
		}
	});

	/**表示距顶边的距离（以像素为单位）。*/
	__getset(0,__proto,'top',function(){
		return this._top;
		},function(value){
		if (this._top !=value){
			this._top=value;
			this.resetLayoutY();
		}
	});

	/**表示距底边的距离（以像素为单位）。*/
	__getset(0,__proto,'bottom',function(){
		return this._bottom;
		},function(value){
		if (this._bottom !=value){
			this._bottom=value;
			this.resetLayoutY();
		}
	});

	/**表示距左边的距离（以像素为单位）。*/
	__getset(0,__proto,'left',function(){
		return this._left;
		},function(value){
		if (this._left !=value){
			this._left=value;
			this.resetLayoutX();
		}
	});

	/**表示距右边的距离（以像素为单位）。*/
	__getset(0,__proto,'right',function(){
		return this._right;
		},function(value){
		if (this._right !=value){
			this._right=value;
			this.resetLayoutX();
		}
	});

	/**表示距垂直方向中心轴的距离（以像素为单位）。*/
	__getset(0,__proto,'centerY',function(){
		return this._centerY;
		},function(value){
		if (this._centerY !=value){
			this._centerY=value;
			this.resetLayoutY();
		}
	});

	__static(Widget,
	['EMPTY',function(){return this.EMPTY=new Widget();}
	]);
	return Widget;
})(Component)


//class laya.wx.mini.MiniLoader extends laya.events.EventDispatcher
var MiniLoader=(function(_super){
	function MiniLoader(){
		MiniLoader.__super.call(this);
	}

	__class(MiniLoader,'laya.wx.mini.MiniLoader',_super);
	var __proto=MiniLoader.prototype;
	/**
	*@private
	*@param url
	*@param type
	*@param cache
	*@param group
	*@param ignoreCache
	*/
	__proto.load=function(url,type,cache,group,ignoreCache){
		(cache===void 0)&& (cache=true);
		(ignoreCache===void 0)&& (ignoreCache=false);
		var thisLoader=this;
		thisLoader._url=url;
		if (url.indexOf("data:image")===0)thisLoader._type=type="image";
		else {
			thisLoader._type=type || (type=Loader.getTypeFromUrl(url));
		}
		thisLoader._cache=cache;
		thisLoader._data=null;
		if (!ignoreCache && Loader.loadedMap[URL.formatURL(url)]){
			thisLoader._data=Loader.loadedMap[URL.formatURL(url)];
			this.event("progress",1);
			this.event("complete",thisLoader._data);
			return;
		}
		if (Loader.parserMap[type] !=null){
			thisLoader._customParse=true;
			if (((Loader.parserMap[type])instanceof laya.utils.Handler ))Loader.parserMap[type].runWith(this);
			else Loader.parserMap[type].call(null,this);
			return;
		};
		var encoding=MiniAdpter.getUrlEncode(url,type);
		var urlType=Utils.getFileExtension(url);
		if ((MiniLoader._fileTypeArr.indexOf(urlType)!=-1)){
			MiniAdpter.EnvConfig.load.call(this,url,type,cache,group,ignoreCache);
			}else {
			if(MiniAdpter.isZiYu && !MiniFileMgr.ziyuFileData[url]){
				url=URL.formatURL(url);
			}
			if(MiniAdpter.isZiYu && MiniFileMgr.ziyuFileData[url]){
				var tempData=MiniFileMgr.ziyuFileData[url];
				thisLoader.onLoaded(tempData);
				return;
			}
			if (!MiniFileMgr.getFileInfo(url)){
				if (MiniFileMgr.isLocalNativeFile(url)){
					if (MiniAdpter.subNativeFiles && MiniAdpter.subNativeheads.length==0){
						for (var key in MiniAdpter.subNativeFiles){
							var tempArr=MiniAdpter.subNativeFiles[key];
							MiniAdpter.subNativeheads=MiniAdpter.subNativeheads.concat(tempArr);
							for (var aa=0;aa < tempArr.length;aa++){
								MiniAdpter.subMaps[tempArr[aa]]=key+"/"+tempArr[aa];
							}
						}
					}
					if(MiniAdpter.subNativeFiles && url.indexOf("/")!=-1){
						var curfileHead=url.split("/")[0]+"/";
						if(curfileHead && MiniAdpter.subNativeheads.indexOf(curfileHead)!=-1){
							var newfileHead=MiniAdpter.subMaps[curfileHead];
							url=url.replace(curfileHead,newfileHead);
						}
					}
					MiniFileMgr.read(url,encoding,new Handler(MiniLoader,MiniLoader.onReadNativeCallBack,[encoding,url,type,cache,group,ignoreCache,thisLoader]));
					return;
				}
				url=URL.formatURL(url);
				if (url.indexOf("http://")!=-1 || url.indexOf("https://")!=-1 && !MiniAdpter.AutoCacheDownFile){
					MiniAdpter.EnvConfig.load.call(thisLoader,url,type,cache,group,ignoreCache);
					}else {
					MiniFileMgr.readFile(url,encoding,new Handler(MiniLoader,MiniLoader.onReadNativeCallBack,[encoding,url,type,cache,group,ignoreCache,thisLoader]),url);
				}
				}else {
				var fileObj=MiniFileMgr.getFileInfo(url);
				fileObj.encoding=fileObj.encoding==null ? "utf8" :fileObj.encoding;
				MiniFileMgr.readFile(url,fileObj.encoding,new Handler(MiniLoader,MiniLoader.onReadNativeCallBack,[encoding,url,type,cache,group,ignoreCache,thisLoader]),url);
			}
		}
	}

	MiniLoader.onReadNativeCallBack=function(encoding,url,type,cache,group,ignoreCache,thisLoader,errorCode,data){
		(cache===void 0)&& (cache=true);
		(ignoreCache===void 0)&& (ignoreCache=false);
		(errorCode===void 0)&& (errorCode=0);
		if (!errorCode){
			var tempData;
			if (type=="json" || type=="atlas" || type=="prefab"){
				tempData=MiniAdpter.getJson(data.data);
				}else if (type=="xml"){
				tempData=Utils.parseXMLFromString(data.data);
				}else {
				tempData=data.data;
			}
			if(!MiniAdpter.isZiYu &&MiniAdpter.isPosMsgYu && type !="arraybuffer"){
				wx.postMessage({url:url,data:tempData,isLoad:"filedata"});
			}
			thisLoader.onLoaded(tempData);
			}else if (errorCode==1){
			MiniAdpter.EnvConfig.load.call(thisLoader,url,type,cache,group,ignoreCache);
		}
	}

	__static(MiniLoader,
	['_fileTypeArr',function(){return this._fileTypeArr=['png','jpg','bmp','jpeg','gif'];}
	]);
	return MiniLoader;
})(EventDispatcher)


//class laya.wx.mini.MiniSound extends laya.events.EventDispatcher
var MiniSound=(function(_super){
	function MiniSound(){
		/**@private **/
		this._sound=null;
		/**
		*@private
		*声音URL
		*/
		this.url=null;
		/**
		*@private
		*是否已加载完成
		*/
		this.loaded=false;
		/**@private **/
		this.readyUrl=null;
		MiniSound.__super.call(this);
	}

	__class(MiniSound,'laya.wx.mini.MiniSound',_super);
	var __proto=MiniSound.prototype;
	/**
	*@private
	*加载声音。
	*@param url 地址。
	*
	*/
	__proto.load=function(url){
		if (!MiniFileMgr.isLocalNativeFile(url)){
			url=URL.formatURL(url);
			}else{
			if (url.indexOf("http://")!=-1 || url.indexOf("https://")!=-1){
				if(MiniFileMgr.loadPath !=""){
					url=url.split(MiniFileMgr.loadPath)[1];
					}else{
					var tempStr=URL.rootPath !="" ? URL.rootPath :URL.basePath;
					if(tempStr !="")
						url=url.split(tempStr)[1];
				}
			}
		}
		this.url=url;
		this.readyUrl=url;
		if (MiniSound._audioCache[this.readyUrl]){
			this.event("complete");
			return;
		}
		if(MiniAdpter.autoCacheFile&&MiniFileMgr.getFileInfo(url)){
			this.onDownLoadCallBack(url,0);
			}else{
			if(!MiniAdpter.autoCacheFile){
				this.onDownLoadCallBack(url,0);
				}else{
				if (MiniFileMgr.isLocalNativeFile(url)){
					tempStr=URL.rootPath !="" ? URL.rootPath :URL.basePath;
					var tempUrl=url;
					if(tempStr !="")
						url=url.split(tempStr)[1];
					if (!url){
						url=tempUrl;
					}
					if (MiniAdpter.subNativeFiles && MiniAdpter.subNativeheads.length==0){
						for (var key in MiniAdpter.subNativeFiles){
							var tempArr=MiniAdpter.subNativeFiles[key];
							MiniAdpter.subNativeheads=MiniAdpter.subNativeheads.concat(tempArr);
							for (var aa=0;aa < tempArr.length;aa++){
								MiniAdpter.subMaps[tempArr[aa]]=key+"/"+tempArr[aa];
							}
						}
					}
					if(MiniAdpter.subNativeFiles && url.indexOf("/")!=-1){
						var curfileHead=url.split("/")[0]+"/";
						if(curfileHead && MiniAdpter.subNativeheads.indexOf(curfileHead)!=-1){
							var newfileHead=MiniAdpter.subMaps[curfileHead];
							url=url.replace(curfileHead,newfileHead);
						}
					}
					this.onDownLoadCallBack(url,0);
					}else{
					MiniFileMgr.downOtherFiles(url,Handler.create(this,this.onDownLoadCallBack,[url]),url);
				}
			}
		}
	}

	/**@private **/
	__proto.onDownLoadCallBack=function(sourceUrl,errorCode){
		if (!errorCode){
			var fileNativeUrl;
			if(MiniAdpter.autoCacheFile){
				if (MiniFileMgr.isLocalNativeFile(sourceUrl)){
					var tempStr=URL.rootPath !="" ? URL.rootPath :URL.basePath;
					var tempUrl=sourceUrl;
					if(tempStr !="" && (sourceUrl.indexOf("http://")!=-1 || sourceUrl.indexOf("https://")!=-1))
						fileNativeUrl=sourceUrl.split(tempStr)[1];
					if(!fileNativeUrl){
						fileNativeUrl=tempUrl;
					}
					}else{
					var fileObj=MiniFileMgr.getFileInfo(sourceUrl);
					if(fileObj && fileObj.md5){
						var fileMd5Name=fileObj.md5;
						fileNativeUrl=MiniFileMgr.getFileNativePath(fileMd5Name);
						}else{
						fileNativeUrl=sourceUrl;
					}
				}
				this._sound=MiniSound._createSound();
				this._sound.src=this.url=fileNativeUrl;
				}else{
				this._sound=MiniSound._createSound();
				this._sound.src=sourceUrl;
			}
			this._sound.onCanplay(MiniSound.bindToThis(this.onCanPlay,this));
			this._sound.onError(MiniSound.bindToThis(this.onError,this));
			}else{
			this.event("error");
		}
	}

	/**@private **/
	__proto.onError=function(error){
		try{
			console.log("-----1---------------minisound-----id:"+MiniSound._id);
			console.log(error);
		}
		catch(error){
			console.log("-----2---------------minisound-----id:"+MiniSound._id);
			console.log(error);
		}
		this.event("error");
		this._sound.offError(null);
	}

	/**@private **/
	__proto.onCanPlay=function(){
		this.loaded=true;
		this.event("complete");
		this._sound.offCanplay(null);
	}

	/**
	*@private
	*播放声音。
	*@param startTime 开始时间,单位秒
	*@param loops 循环次数,0表示一直循环
	*@return 声道 SoundChannel 对象。
	*
	*/
	__proto.play=function(startTime,loops){
		(startTime===void 0)&& (startTime=0);
		(loops===void 0)&& (loops=0);
		var tSound;
		if (this.url==SoundManager._bgMusic){
			if (!MiniSound._musicAudio)MiniSound._musicAudio=MiniSound._createSound();
			tSound=MiniSound._musicAudio;
			}else {
			if(MiniSound._audioCache[this.readyUrl]){
				tSound=MiniSound._audioCache[this.readyUrl]._sound;
				}else{
				tSound=MiniSound._createSound();
			}
		}
		if(MiniAdpter.autoCacheFile&&MiniFileMgr.getFileInfo(this.url)){
			var fileNativeUrl;
			var fileObj=MiniFileMgr.getFileInfo(this.url);
			var fileMd5Name=fileObj.md5;
			tSound.src=this.url=MiniFileMgr.getFileNativePath(fileMd5Name);
			}else{
			tSound.src=this.url;
		};
		var channel=new MiniSoundChannel(tSound,this);
		channel.url=this.url;
		channel.loops=loops;
		channel.loop=(loops===0 ? true :false);
		channel.startTime=startTime;
		channel.play();
		SoundManager.addChannel(channel);
		return channel;
	}

	/**
	*@private
	*释放声音资源。
	*
	*/
	__proto.dispose=function(){
		var ad=MiniSound._audioCache[this.readyUrl];
		if (ad){
			ad.src="";
			if(ad._sound){
				ad._sound.destroy();
				ad._sound=null;
				ad=null;
			}
			delete MiniSound._audioCache[this.readyUrl];
		}
	}

	/**
	*@private
	*获取总时间。
	*/
	__getset(0,__proto,'duration',function(){
		return this._sound.duration;
	});

	MiniSound._createSound=function(){
		MiniSound._id++;
		return MiniAdpter.window.wx.createInnerAudioContext();
	}

	MiniSound.bindToThis=function(fun,scope){
		var rst=fun;
		rst=fun.bind(scope);;
		return rst;
	}

	MiniSound._musicAudio=null;
	MiniSound._id=0;
	MiniSound._audioCache={};
	return MiniSound;
})(EventDispatcher)


//class laya.display.css.TextStyle extends laya.display.css.SpriteStyle
var TextStyle=(function(_super){
	function TextStyle(){
		/**
		*表示使用此文本格式的文本是否为斜体。
		*@default false
		*/
		this.italic=false;
		/**
		*<p>表示使用此文本格式的文本段落的水平对齐方式。</p>
		*@default "left"
		*/
		//this.align=null;
		/**
		*<p>表示使用此文本格式的文本字段是否自动换行。</p>
		*如果 wordWrap 的值为 true，则该文本字段自动换行；如果值为 false，则该文本字段不自动换行。
		*@default false。
		*/
		//this.wordWrap=false;
		/**
		*<p>垂直行间距（以像素为单位）</p>
		*/
		//this.leading=NaN;
		/**
		*<p>默认边距信息</p>
		*<p>[左边距，上边距，右边距，下边距]（边距以像素为单位）</p>
		*/
		//this.padding=null;
		/**
		*文本背景颜色，以字符串表示。
		*/
		//this.bgColor=null;
		/**
		*文本边框背景颜色，以字符串表示。
		*/
		//this.borderColor=null;
		/**
		*<p>指定文本字段是否是密码文本字段。</p>
		*如果此属性的值为 true，则文本字段被视为密码文本字段，并使用星号而不是实际字符来隐藏输入的字符。如果为 false，则不会将文本字段视为密码文本字段。
		*/
		//this.asPassword=false;
		/**
		*<p>描边宽度（以像素为单位）。</p>
		*默认值0，表示不描边。
		*@default 0
		*/
		//this.stroke=NaN;
		/**
		*<p>描边颜色，以字符串表示。</p>
		*@default "#000000";
		*/
		//this.strokeColor=null;
		/**是否为粗体*/
		//this.bold=false;
		/**是否显示下划线*/
		//this.underline=false;
		/**下划线颜色*/
		//this.underlineColor=null;
		/**当前使用的位置字体。*/
		//this.currBitmapFont=null;
		TextStyle.__super.call(this);
	}

	__class(TextStyle,'laya.display.css.TextStyle',_super);
	var __proto=TextStyle.prototype;
	__proto.reset=function(){
		_super.prototype.reset.call(this);
		this.italic=false;
		this.align="left";
		this.wordWrap=false;
		this.leading=0;
		this.padding=[0,0,0,0];
		this.bgColor=null;
		this.borderColor=null;
		this.asPassword=false;
		this.stroke=0;
		this.strokeColor="#000000";
		this.bold=false;
		this.underline=false;
		this.underlineColor=null;
		this.currBitmapFont=null;
		return this;
	}

	__proto.recover=function(){
		if (this===TextStyle.EMPTY)
			return;
		Pool.recover("TextStyle",this.reset());
	}

	/**@inheritDoc */
	__proto.render=function(sprite,context,x,y){
		(this.bgColor || this.borderColor)&& context.drawRect(x,y,sprite.width,sprite.height,this.bgColor,this.borderColor,1);
	}

	TextStyle.create=function(){
		return Pool.getItemByClass("TextStyle",TextStyle);
	}

	TextStyle.EMPTY=new TextStyle();
	return TextStyle;
})(SpriteStyle)


//class laya.filters.ColorFilter extends laya.filters.Filter
var ColorFilter=(function(_super){
	function ColorFilter(mat){
		/**@private */
		//this._mat=null;
		/**@private */
		//this._alpha=null;
		/**当前使用的矩阵*/
		//this._matrix=null;
		ColorFilter.__super.call(this);
		if (!mat)mat=this._copyMatrix(ColorFilter.IDENTITY_MATRIX);
		this._mat=new Float32Array(16);
		this._alpha=new Float32Array(4);
		this.setByMatrix(mat);
		this._action=new ColorFilterAction();
		this._action.data=this;
	}

	__class(ColorFilter,'laya.filters.ColorFilter',_super);
	var __proto=ColorFilter.prototype;
	Laya.imps(__proto,{"laya.filters.IFilter":true})
	/**
	*设置为灰色滤镜
	*/
	__proto.gray=function(){
		return this.setByMatrix(ColorFilter.GRAY_MATRIX);
	}

	/**
	*设置为变色滤镜
	*@param red 红色增量,范围:0~255
	*@param green 绿色增量,范围:0~255
	*@param blue 蓝色增量,范围:0~255
	*@param alpha alpha,范围:0~1
	*/
	__proto.color=function(red,green,blue,alpha){
		(red===void 0)&& (red=0);
		(green===void 0)&& (green=0);
		(blue===void 0)&& (blue=0);
		(alpha===void 0)&& (alpha=1);
		return this.setByMatrix([1,0,0,0,red,0,1,0,0,green,0,0,1,0,blue,0,0,0,1,alpha]);
	}

	/**
	*设置矩阵数据
	*@param matrix 由 20 个项目（排列成 4 x 5 矩阵）组成的数组
	*@return this
	*/
	__proto.setByMatrix=function(matrix){
		if (this._matrix !=matrix)this._copyMatrix(matrix);
		var j=0;
		var z=0;
		for (var i=0;i < 20;i++){
			if (i % 5 !=4){
				this._mat[j++]=matrix[i];
				}else {
				this._alpha[z++]=matrix[i];
			}
		}
		return this;
	}

	/**
	*调整颜色，包括亮度，对比度，饱和度和色调
	*@param brightness 亮度,范围:-100~100
	*@param contrast 对比度,范围:-100~100
	*@param saturation 饱和度,范围:-100~100
	*@param hue 色调,范围:-180~180
	*@return this
	*/
	__proto.adjustColor=function(brightness,contrast,saturation,hue){
		this.adjustHue(hue);
		this.adjustContrast(contrast);
		this.adjustBrightness(brightness);
		this.adjustSaturation(saturation);
		return this;
	}

	/**
	*调整亮度
	*@param brightness 亮度,范围:-100~100
	*@return this
	*/
	__proto.adjustBrightness=function(brightness){
		brightness=this._clampValue(brightness,100);
		if (brightness==0 || isNaN(brightness))return this;
		return this._multiplyMatrix([1,0,0,0,brightness,0,1,0,0,brightness,0,0,1,0,brightness,0,0,0,1,0,0,0,0,0,1]);
	}

	/**
	*调整对比度
	*@param contrast 对比度,范围:-100~100
	*@return this
	*/
	__proto.adjustContrast=function(contrast){
		contrast=this._clampValue(contrast,100);
		if (contrast==0 || isNaN(contrast))return this;
		var x=NaN;
		if (contrast < 0){
			x=127+contrast / 100 *127
			}else {
			x=contrast % 1;
			if (x==0){
				x=ColorFilter.DELTA_INDEX[contrast];
				}else {
				x=ColorFilter.DELTA_INDEX[(contrast << 0)] *(1-x)+ColorFilter.DELTA_INDEX[(contrast << 0)+1] *x;
			}
			x=x *127+127;
		};
		var x1=x / 127;
		var x2=(127-x)*0.5;
		return this._multiplyMatrix([x1,0,0,0,x2,0,x1,0,0,x2,0,0,x1,0,x2,0,0,0,1,0,0,0,0,0,1]);
	}

	/**
	*调整饱和度
	*@param saturation 饱和度,范围:-100~100
	*@return this
	*/
	__proto.adjustSaturation=function(saturation){
		saturation=this._clampValue(saturation,100);
		if (saturation==0 || isNaN(saturation))return this;
		var x=1+((saturation > 0)? 3 *saturation / 100 :saturation / 100);
		var dx=1-x;
		var r=0.3086 *dx;
		var g=0.6094 *dx;
		var b=0.0820 *dx;
		return this._multiplyMatrix([r+x,g,b,0,0,r,g+x,b,0,0,r,g,b+x,0,0,0,0,0,1,0,0,0,0,0,1]);
	}

	/**
	*调整色调
	*@param hue 色调,范围:-180~180
	*@return this
	*/
	__proto.adjustHue=function(hue){
		hue=this._clampValue(hue,180)/ 180 *Math.PI;
		if (hue==0 || isNaN(hue))return this;
		var cos=Math.cos(hue);
		var sin=Math.sin(hue);
		var r=0.213;
		var g=0.715;
		var b=0.072;
		return this._multiplyMatrix([r+cos *(1-r)+sin *(-r),g+cos *(-g)+sin *(-g),b+cos *(-b)+sin *(1-b),0,0,r+cos *(-r)+sin *(0.143),g+cos *(1-g)+sin *(0.140),b+cos *(-b)+sin *(-0.283),0,0,r+cos *(-r)+sin *(-(1-r)),g+cos *(-g)+sin *(g),b+cos *(1-b)+sin *(b),0,0,0,0,0,1,0,0,0,0,0,1]);
	}

	/**
	*重置成单位矩阵，去除滤镜效果
	*/
	__proto.reset=function(){
		return this.setByMatrix(this._copyMatrix(ColorFilter.IDENTITY_MATRIX));
	}

	/**
	*矩阵乘法
	*@param matrix
	*@return this
	*/
	__proto._multiplyMatrix=function(matrix){
		var col=[];
		this._matrix=this._fixMatrix(this._matrix);
		for (var i=0;i < 5;i++){
			for (var j=0;j < 5;j++){
				col[j]=this._matrix[j+i *5];
			}
			for (j=0;j < 5;j++){
				var val=0;
				for (var k=0;k < 5;k++){
					val+=matrix[j+k *5] *col[k];
				}
				this._matrix[j+i *5]=val;
			}
		}
		return this.setByMatrix(this._matrix);
	}

	/**
	*规范值的范围
	*@param val 当前值
	*@param limit 值的范围-limit~limit
	*/
	__proto._clampValue=function(val,limit){
		return Math.min(limit,Math.max(-limit,val));
	}

	/**
	*规范矩阵,将矩阵调整到正确的大小
	*@param matrix 需要调整的矩阵
	*/
	__proto._fixMatrix=function(matrix){
		if (matrix==null)return ColorFilter.IDENTITY_MATRIX;
		if (matrix.length < 25)matrix=matrix.slice(0,matrix.length).concat(ColorFilter.IDENTITY_MATRIX.slice(matrix.length,25));
		else if (matrix.length > 25)matrix=matrix.slice(0,25);
		return matrix;
	}

	/**
	*复制矩阵
	*/
	__proto._copyMatrix=function(matrix){
		var len=25;
		if (!this._matrix)this._matrix=[];
		for (var i=0;i < len;i++){
			this._matrix[i]=matrix[i];
		}
		return this._matrix;
	}

	/**@private */
	__getset(0,__proto,'type',function(){
		return 0x20;
	});

	ColorFilter.LENGTH=25;
	__static(ColorFilter,
	['DELTA_INDEX',function(){return this.DELTA_INDEX=[0,0.01,0.02,0.04,0.05,0.06,0.07,0.08,0.1,0.11,0.12,0.14,0.15,0.16,0.17,0.18,0.20,0.21,0.22,0.24,0.25,0.27,0.28,0.30,0.32,0.34,0.36,0.38,0.40,0.42,0.44,0.46,0.48,0.5,0.53,0.56,0.59,0.62,0.65,0.68,0.71,0.74,0.77,0.80,0.83,0.86,0.89,0.92,0.95,0.98,1.0,1.06,1.12,1.18,1.24,1.30,1.36,1.42,1.48,1.54,1.60,1.66,1.72,1.78,1.84,1.90,1.96,2.0,2.12,2.25,2.37,2.50,2.62,2.75,2.87,3.0,3.2,3.4,3.6,3.8,4.0,4.3,4.7,4.9,5.0,5.5,6.0,6.5,6.8,7.0,7.3,7.5,7.8,8.0,8.4,8.7,9.0,9.4,9.6,9.8,10.0];},'GRAY_MATRIX',function(){return this.GRAY_MATRIX=[0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0];},'IDENTITY_MATRIX',function(){return this.IDENTITY_MATRIX=[1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1];}
	]);
	return ColorFilter;
})(Filter)


//class laya.ui.UIEvent extends laya.events.Event
var UIEvent=(function(_super){
	function UIEvent(){
		UIEvent.__super.call(this);;
	}

	__class(UIEvent,'laya.ui.UIEvent',_super);
	UIEvent.SHOW_TIP="showtip";
	UIEvent.HIDE_TIP="hidetip";
	return UIEvent;
})(Event)


//class laya.display.Sprite extends laya.display.Node
var Sprite=(function(_super){
	function Sprite(){
		/**@private */
		this._x=0;
		/**@private */
		this._y=0;
		/**@private */
		this._width=0;
		/**@private */
		this._height=0;
		/**@private */
		this._visible=true;
		/**@private 鼠标状态，0:auto,1:mouseEnabled=false,2:mouseEnabled=true。*/
		this._mouseState=0;
		/**@private z排序，数值越大越靠前。*/
		this._zOrder=0;
		/**@private */
		this._renderType=0;
		/**@private */
		this._transform=null;
		/**@private */
		this._tfChanged=false;
		/**@private */
		this._texture=null;
		/**@private */
		this._boundStyle=null;
		/**@private */
		this._graphics=null;
		/**
		*<p>鼠标事件与此对象的碰撞检测是否可穿透。碰撞检测发生在鼠标事件的捕获阶段，此阶段引擎会从stage开始递归检测stage及其子对象，直到找到命中的目标对象或者未命中任何对象。</p>
		*<p>穿透表示鼠标事件发生的位置处于本对象绘图区域内时，才算命中，而与对象宽高和值为Rectangle对象的hitArea属性无关。如果sprite.hitArea值是HitArea对象，表示显式声明了此对象的鼠标事件响应区域，而忽略对象的宽高、mouseThrough属性。</p>
		*<p>影响对象鼠标事件响应区域的属性为：width、height、hitArea，优先级顺序为：hitArea(type:HitArea)>hitArea(type:Rectangle)>width/height。</p>
		*@default false 不可穿透，此对象的鼠标响应区域由width、height、hitArea属性决定。</p>
		*/
		this.mouseThrough=false;
		/**
		*<p>指定是否自动计算宽高数据。默认值为 false 。</p>
		*<p>Sprite宽高默认为0，并且不会随着绘制内容的变化而变化，如果想根据绘制内容获取宽高，可以设置本属性为true，或者通过getBounds方法获取。设置为true，对性能有一定影响。</p>
		*/
		this.autoSize=false;
		/**
		*<p>指定鼠标事件检测是优先检测自身，还是优先检测其子对象。鼠标事件检测发生在鼠标事件的捕获阶段，此阶段引擎会从stage开始递归检测stage及其子对象，直到找到命中的目标对象或者未命中任何对象。</p>
		*<p>如果为false，优先检测子对象，当有子对象被命中时，中断检测，获得命中目标。如果未命中任何子对象，最后再检测此对象；如果为true，则优先检测本对象，如果本对象没有被命中，直接中断检测，表示没有命中目标；如果本对象被命中，则进一步递归检测其子对象，以确认最终的命中目标。</p>
		*<p>合理使用本属性，能减少鼠标事件检测的节点，提高性能。可以设置为true的情况：开发者并不关心此节点的子节点的鼠标事件检测结果，也就是以此节点作为其子节点的鼠标事件检测依据。</p>
		*<p>Stage对象和UI的View组件默认为true。</p>
		*@default false 优先检测此对象的子对象，当递归检测完所有子对象后，仍然没有找到目标对象，最后再检测此对象。
		*/
		this.hitTestPrior=false;
		Sprite.__super.call(this);
		this._repaint=0;
		this._style=SpriteStyle.EMPTY;
		this._cacheStyle=CacheStyle.EMPTY;
	}

	__class(Sprite,'laya.display.Sprite',_super);
	var __proto=Sprite.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._style && this._style.recover();
		this._cacheStyle && this._cacheStyle.recover();
		this._boundStyle && this._boundStyle.recover();
		this._style=null;
		this._cacheStyle=null;
		this._boundStyle=null;
		this._transform=null;
		if (this._graphics&&this._graphics.autoDestroy){
			this._graphics.destroy();
		}
		this._graphics=null;
		this.texture=null;
	}

	/**根据zOrder进行重新排序。*/
	__proto.updateZOrder=function(){
		Utils.updateOrder(this._children)&& this.repaint();
	}

	/**
	*@private
	*/
	__proto._getBoundsStyle=function(){
		if (!this._boundStyle)this._boundStyle=BoundsStyle.create();
		return this._boundStyle;
	}

	/**@private */
	__proto._setCustomRender=function(){}
	/**@private */
	__proto._setCacheAs=function(value){}
	/**
	*更新_cnavas相关的状态
	*/
	__proto._checkCanvasEnable=function(){
		var tEnable=this._cacheStyle.needEnableCanvasRender();
		this._getCacheStyle().enableCanvasRender=tEnable;
		if (tEnable){
			if (this._cacheStyle.needBitmapCache()){
				this._cacheStyle.cacheAs="bitmap";
				}else {
				this._cacheStyle.cacheAs=this._cacheStyle.userSetCache;
			}
			this._cacheStyle.reCache=true;
			this._renderType |=0x08;
			}else {
			this._cacheStyle.cacheAs="none";
			this._cacheStyle.releaseContext();
			this._renderType &=~0x08;
		}
		this._setCacheAs(this._cacheStyle.cacheAs);
		this._setRenderType(this._renderType);
	}

	/**在设置cacheAs的情况下，调用此方法会重新刷新缓存。*/
	__proto.reCache=function(){
		this._cacheStyle.reCache=true;
		this._repaint |=0x02;
	}

	__proto.getRepaint=function(){
		return this._repaint;
	}

	/**@private */
	__proto._setX=function(value){
		this._x=value;
	}

	/**@private */
	__proto._setY=function(value){
		this._y=value;
	}

	/**
	*设置对象bounds大小，如果有设置，则不再通过getBounds计算，合理使用能提高性能。
	*@param bound bounds矩形区域
	*/
	__proto.setSelfBounds=function(bound){
		this._getBoundsStyle().userBounds=bound;
	}

	/**
	*<p>获取本对象在父容器坐标系的矩形显示区域。</p>
	*<p><b>注意：</b>计算量较大，尽量少用。</p>
	*@return 矩形区域。
	*/
	__proto.getBounds=function(){
		return this._getBoundsStyle().bounds=Rectangle._getWrapRec(this._boundPointsToParent());
	}

	/**
	*获取本对象在自己坐标系的矩形显示区域。
	*<p><b>注意：</b>计算量较大，尽量少用。</p>
	*@return 矩形区域。
	*/
	__proto.getSelfBounds=function(){
		if (this._boundStyle && this._boundStyle.userBounds)return this._boundStyle.userBounds;
		if (!this._graphics && this._children.length===0&&!this._texture)return Rectangle.TEMP.setTo(0,0,0,0);
		return this._getBoundsStyle().bounds=Rectangle._getWrapRec(this._getBoundPointsM(false));
	}

	/**
	*@private
	*获取本对象在父容器坐标系的显示区域多边形顶点列表。
	*当显示对象链中有旋转时，返回多边形顶点列表，无旋转时返回矩形的四个顶点。
	*@param ifRotate （可选）之前的对象链中是否有旋转。
	*@return 顶点列表。结构：[x1,y1,x2,y2,x3,y3,...]。
	*/
	__proto._boundPointsToParent=function(ifRotate){
		(ifRotate===void 0)&& (ifRotate=false);
		var pX=0,pY=0;
		if (this._style){
			pX=this.pivotX;
			pY=this.pivotY;
			ifRotate=ifRotate || (this._style.rotation!==0);
			if (this._style.scrollRect){
				pX+=this._style.scrollRect.x;
				pY+=this._style.scrollRect.y;
			}
		};
		var pList=this._getBoundPointsM(ifRotate);
		if (!pList || pList.length < 1)return pList;
		if (pList.length !=8){
			pList=ifRotate ? GrahamScan.scanPList(pList):Rectangle._getWrapRec(pList,Rectangle.TEMP)._getBoundPoints();
		}
		if (!this.transform){
			Utils.transPointList(pList,this._x-pX,this._y-pY);
			return pList;
		};
		var tPoint=Point.TEMP;
		var i=0,len=pList.length;
		for (i=0;i < len;i+=2){
			tPoint.x=pList[i];
			tPoint.y=pList[i+1];
			this.toParentPoint(tPoint);
			pList[i]=tPoint.x;
			pList[i+1]=tPoint.y;
		}
		return pList;
	}

	/**
	*返回此实例中的绘图对象（ <code>Graphics</code> ）的显示区域，不包括子对象。
	*@param realSize （可选）使用图片的真实大小，默认为false
	*@return 一个 Rectangle 对象，表示获取到的显示区域。
	*/
	__proto.getGraphicBounds=function(realSize){
		(realSize===void 0)&& (realSize=false);
		if (!this._graphics)return Rectangle.TEMP.setTo(0,0,0,0);
		return this._graphics.getBounds(realSize);
	}

	/**
	*@private
	*获取自己坐标系的显示区域多边形顶点列表
	*@param ifRotate （可选）当前的显示对象链是否由旋转
	*@return 顶点列表。结构：[x1,y1,x2,y2,x3,y3,...]。
	*/
	__proto._getBoundPointsM=function(ifRotate){
		(ifRotate===void 0)&& (ifRotate=false);
		if (this._boundStyle && this._boundStyle.userBounds)return this._boundStyle.userBounds._getBoundPoints();
		if (!this._boundStyle)this._getBoundsStyle();
		if (!this._boundStyle.temBM)this._boundStyle.temBM=[];
		if (this._style.scrollRect){
			var rst=Utils.clearArray(this._boundStyle.temBM);
			var rec=Rectangle.TEMP;
			rec.copyFrom(this._style.scrollRect);
			Utils.concatArray(rst,rec._getBoundPoints());
			return rst;
		};
		var pList;
		if (this._graphics){
			pList=this._graphics.getBoundPoints();
			}else {
			pList=Utils.clearArray(this._boundStyle.temBM);
			if (this._texture){
				rec=Rectangle.TEMP;
				rec.setTo(0,0,this._texture.width,this._texture.height);
				Utils.concatArray(pList,rec._getBoundPoints());
			}
		};
		var child;
		var cList;
		var __childs;
		__childs=this._children;
		for (var i=0,n=__childs.length;i < n;i++){
			child=__childs [i];
			if ((child instanceof laya.display.Sprite )&& child._visible===true){
				cList=child._boundPointsToParent(ifRotate);
				if (cList)
					pList=pList ? Utils.concatArray(pList,cList):cList;
			}
		}
		return pList;
	}

	/**
	*@private
	*获取cache数据。
	*@return cache数据 CacheStyle 。
	*/
	__proto._getCacheStyle=function(){
		this._cacheStyle===CacheStyle.EMPTY && (this._cacheStyle=CacheStyle.create());
		return this._cacheStyle;
	}

	/**
	*@private
	*获取样式。
	*@return 样式 Style 。
	*/
	__proto.getStyle=function(){
		this._style===SpriteStyle.EMPTY && (this._style=SpriteStyle.create());
		return this._style;
	}

	/**
	*@private
	*设置样式。
	*@param value 样式。
	*/
	__proto.setStyle=function(value){
		this._style=value;
	}

	/**@private */
	__proto._setScaleX=function(value){
		this._style.scaleX=value;
	}

	/**@private */
	__proto._setScaleY=function(value){
		this._style.scaleY=value;
	}

	/**@private */
	__proto._setRotation=function(value){
		this._style.rotation=value;
	}

	/**@private */
	__proto._setSkewX=function(value){
		this._style.skewX=value;
	}

	/**@private */
	__proto._setSkewY=function(value){
		this._style.skewY=value;
	}

	/**@private */
	__proto._createTransform=function(){
		return Matrix.create();
	}

	/**@private */
	__proto._adjustTransform=function(){
		this._tfChanged=false;
		var style=this._style;
		var sx=style.scaleX,sy=style.scaleY;
		var m=this._transform || (this._transform=this._createTransform());
		if (style.rotation || sx!==1 || sy!==1 || style.skewX!==0 || style.skewY!==0){
			m._bTransform=true;
			var skx=(style.rotation-style.skewX)*0.0174532922222222;
			var sky=(style.rotation+style.skewY)*0.0174532922222222;
			var cx=Math.cos(sky);
			var ssx=Math.sin(sky);
			var cy=Math.sin(skx);
			var ssy=Math.cos(skx);
			m.a=sx *cx;
			m.b=sx *ssx;
			m.c=-sy *cy;
			m.d=sy *ssy;
			m.tx=m.ty=0;
			}else {
			m.identity();
			this._renderType &=~0x02;
			this._setRenderType(this._renderType);
		}
		return m;
	}

	/**@private */
	__proto._setTransform=function(value){}
	/**@private */
	__proto._setPivotX=function(value){
		var style=this.getStyle();
		style.pivotX=value;
	}

	/**@private */
	__proto._getPivotX=function(){
		return this._style.pivotX;
	}

	/**@private */
	__proto._setPivotY=function(value){
		var style=this.getStyle();
		style.pivotY=value;
	}

	/**@private */
	__proto._getPivotY=function(){
		return this._style.pivotY;
	}

	/**@private */
	__proto._setAlpha=function(value){
		if (this._style.alpha!==value){
			var style=this.getStyle();
			style.alpha=value;
			if (value!==1)this._renderType |=0x01;
			else this._renderType &=~0x01;
			this._setRenderType(this._renderType);
			this.parentRepaint();
		}
	}

	/**@private */
	__proto._getAlpha=function(){
		return this._style.alpha;
	}

	/**@private */
	__proto._setBlendMode=function(value){}
	/**@private */
	__proto._setGraphics=function(value){}
	/**@private */
	__proto._setGraphicsCallBack=function(){}
	/**@private */
	__proto._setScrollRect=function(value){}
	/**
	*<p>设置坐标位置。相当于分别设置x和y属性。</p>
	*<p>因为返回值为Sprite对象本身，所以可以使用如下语法：spr.pos(...).scale(...);</p>
	*@param x X轴坐标。
	*@param y Y轴坐标。
	*@param speedMode （可选）是否极速模式，正常是调用this.x=value进行赋值，极速模式直接调用内部函数处理，如果未重写x,y属性，建议设置为急速模式性能更高。
	*@return 返回对象本身。
	*/
	__proto.pos=function(x,y,speedMode){
		(speedMode===void 0)&& (speedMode=false);
		if (this._x!==x || this._y!==y){
			if (this.destroyed)return this;
			if (speedMode){
				this._setX(x);
				this._setY(y);
				this.parentRepaint(0x02);
				var p=this._cacheStyle.maskParent;
				if (p){
					p.repaint(0x02);
				}
				}else {
				this.x=x;
				this.y=y;
			}
		}
		return this;
	}

	/**
	*<p>设置轴心点。相当于分别设置pivotX和pivotY属性。</p>
	*<p>因为返回值为Sprite对象本身，所以可以使用如下语法：spr.pivot(...).pos(50,100);</p>
	*@param x X轴心点。
	*@param y Y轴心点。
	*@return 返回对象本身。
	*/
	__proto.pivot=function(x,y){
		this.pivotX=x;
		this.pivotY=y;
		return this;
	}

	/**
	*<p>设置宽高。相当于分别设置width和height属性。</p>
	*<p>因为返回值为Sprite对象本身，所以可以使用如下语法：spr.size(...).pos(50,100);</p>
	*@param width 宽度值。
	*@param hegiht 高度值。
	*@return 返回对象本身。
	*/
	__proto.size=function(width,height){
		this.width=width;
		this.height=height;
		return this;
	}

	/**
	*<p>设置缩放。相当于分别设置scaleX和scaleY属性。</p>
	*<p>因为返回值为Sprite对象本身，所以可以使用如下语法：spr.scale(...).pos(50,100);</p>
	*@param scaleX X轴缩放比例。
	*@param scaleY Y轴缩放比例。
	*@param speedMode （可选）是否极速模式，正常是调用this.scaleX=value进行赋值，极速模式直接调用内部函数处理，如果未重写scaleX,scaleY属性，建议设置为急速模式性能更高。
	*@return 返回对象本身。
	*/
	__proto.scale=function(scaleX,scaleY,speedMode){
		(speedMode===void 0)&& (speedMode=false);
		var style=this.getStyle();
		if (style.scaleX !=scaleX || style.scaleY !=scaleY){
			if (this.destroyed)return this;
			if (speedMode){
				this._setScaleX(scaleX);
				this._setScaleY(scaleY);
				this._setTranformChange();
				}else {
				this.scaleX=scaleX;
				this.scaleY=scaleY;
			}
		}
		return this;
	}

	/**
	*<p>设置倾斜角度。相当于分别设置skewX和skewY属性。</p>
	*<p>因为返回值为Sprite对象本身，所以可以使用如下语法：spr.skew(...).pos(50,100);</p>
	*@param skewX 水平倾斜角度。
	*@param skewY 垂直倾斜角度。
	*@return 返回对象本身
	*/
	__proto.skew=function(skewX,skewY){
		this.skewX=skewX;
		this.skewY=skewY;
		return this;
	}

	/**
	*更新、呈现显示对象。由系统调用。
	*@param context 渲染的上下文引用。
	*@param x X轴坐标。
	*@param y Y轴坐标。
	*/
	__proto.render=function(ctx,x,y){
		Stat.spriteCount++;
		RenderSprite.renders[this._renderType]._fun(this,ctx,x+this._x,y+this._y);
		this._repaint=0;
	}

	/**
	*<p>绘制 当前<code>Sprite</code> 到 <code>Canvas</code> 上，并返回一个HtmlCanvas。</p>
	*<p>绘制的结果可以当作图片源，再次绘制到其他Sprite里面，示例：</p>
	*
	*var htmlCanvas:HTMLCanvas=sprite.drawToCanvas(100,100,0,0);//把精灵绘制到canvas上面
	*var sp:Sprite=new Sprite();//创建精灵
	*sp.graphics.drawTexture(htmlCanvas.getTexture());//把截图绘制到精灵上
	*Laya.stage.addChild(sp);//把精灵显示到舞台
	*
	*<p>也可以获取原始图片数据，分享到网上，从而实现截图效果，示例：</p>
	*
	*var htmlCanvas:HTMLCanvas=sprite.drawToCanvas(100,100,0,0);//把精灵绘制到canvas上面
	*htmlCanvas.toBase64("image/png",0.9,callBack);//打印图片base64信息，可以发给服务器或者保存为图片
	*
	*@param canvasWidth 画布宽度。
	*@param canvasHeight 画布高度。
	*@param x 绘制的 X 轴偏移量。
	*@param y 绘制的 Y 轴偏移量。
	*@return HTMLCanvas 对象。
	*/
	__proto.drawToCanvas=function(canvasWidth,canvasHeight,offsetX,offsetY){
		return RunDriver.drawToCanvas(this,this._renderType,canvasWidth,canvasHeight,offsetX,offsetY);
	}

	/**
	*<p>自定义更新、呈现显示对象。一般用来扩展渲染模式，请合理使用，可能会导致在加速器上无法渲染。</p>
	*<p><b>注意</b>不要在此函数内增加或删除树节点，否则会对树节点遍历造成影响。</p>
	*@param context 渲染的上下文引用。
	*@param x X轴坐标。
	*@param y Y轴坐标。
	*/
	__proto.customRender=function(context,x,y){
		this._repaint=0x03;
	}

	/**
	*@private
	*应用滤镜。
	*/
	__proto._applyFilters=function(){
		if (Render.isWebGL)return;
		var _filters;
		_filters=this._cacheStyle.filters;
		if (!_filters || _filters.length < 1)return;
		for (var i=0,n=_filters.length;i < n;i++){
			_filters[i]._action && _filters[i]._action.apply(this._cacheStyle);
		}
	}

	/**@private */
	__proto._setColorFilter=function(value){}
	/**
	*@private
	*查看当前原件中是否包含发光滤镜。
	*@return 一个 Boolean 值，表示当前原件中是否包含发光滤镜。
	*/
	__proto._isHaveGlowFilter=function(){
		var i=0,len=0;
		if (this.filters){
			for (i=0;i < this.filters.length;i++){
				if (this.filters[i].type==0x08){
					return true;
				}
			}
		}
		for (i=0,len=this._children.length;i < len;i++){
			if (this._children[i]._isHaveGlowFilter()){
				return true;
			}
		}
		return false;
	}

	/**
	*把本地坐标转换为相对stage的全局坐标。
	*@param point 本地坐标点。
	*@param createNewPoint （可选）是否创建一个新的Point对象作为返回值，默认为false，使用输入的point对象返回，减少对象创建开销。
	*@param globalNode global节点，默认为Laya.stage
	*@return 转换后的坐标的点。
	*/
	__proto.localToGlobal=function(point,createNewPoint,globalNode){
		(createNewPoint===void 0)&& (createNewPoint=false);
		if (createNewPoint===true){
			point=new Point(point.x,point.y);
		};
		var ele=this;globalNode=globalNode|| Laya.stage;
		while (ele){
			if (ele==globalNode)break ;
			point=ele.toParentPoint(point);
			ele=ele.parent;
		}
		return point;
	}

	/**
	*把stage的全局坐标转换为本地坐标。
	*@param point 全局坐标点。
	*@param createNewPoint （可选）是否创建一个新的Point对象作为返回值，默认为false，使用输入的point对象返回，减少对象创建开销。
	*@param globalNode global节点，默认为Laya.stage
	*@return 转换后的坐标的点。
	*/
	__proto.globalToLocal=function(point,createNewPoint,globalNode){
		(createNewPoint===void 0)&& (createNewPoint=false);
		if (createNewPoint){
			point=new Point(point.x,point.y);
		};
		var ele=this;
		var list=[];globalNode=globalNode|| Laya.stage;
		while (ele){
			if (ele==globalNode)break ;
			list.push(ele);
			ele=ele.parent;
		};
		var i=list.length-1;
		while (i >=0){
			ele=list[i];
			point=ele.fromParentPoint(point);
			i--;
		}
		return point;
	}

	/**
	*将本地坐标系坐标转转换到父容器坐标系。
	*@param point 本地坐标点。
	*@return 转换后的点。
	*/
	__proto.toParentPoint=function(point){
		if (!point)return point;
		point.x-=this.pivotX;
		point.y-=this.pivotY;
		if (this.transform){
			this._transform.transformPoint(point);
		}
		point.x+=this._x;
		point.y+=this._y;
		var scroll=this._style.scrollRect;
		if (scroll){
			point.x-=scroll.x;
			point.y-=scroll.y;
		}
		return point;
	}

	/**
	*将父容器坐标系坐标转换到本地坐标系。
	*@param point 父容器坐标点。
	*@return 转换后的点。
	*/
	__proto.fromParentPoint=function(point){
		if (!point)return point;
		point.x-=this._x;
		point.y-=this._y;
		var scroll=this._style.scrollRect;
		if (scroll){
			point.x+=scroll.x;
			point.y+=scroll.y;
		}
		if (this.transform){
			this._transform.invertTransformPoint(point);
		}
		point.x+=this.pivotX;
		point.y+=this.pivotY;
		return point;
	}

	/**
	*<p>增加事件侦听器，以使侦听器能够接收事件通知。</p>
	*<p>如果侦听鼠标事件，则会自动设置自己和父亲节点的属性 mouseEnabled 的值为 true(如果父节点mouseEnabled=false，则停止设置父节点mouseEnabled属性)。</p>
	*@param type 事件的类型。
	*@param caller 事件侦听函数的执行域。
	*@param listener 事件侦听函数。
	*@param args （可选）事件侦听函数的回调参数。
	*@return 此 EventDispatcher 对象。
	*/
	__proto.on=function(type,caller,listener,args){
		if (this._mouseState!==1 && this.isMouseEvent(type)){
			this.mouseEnabled=true;
			this._setBit(0x40,true);
			if (this._parent){
				this._$2__onDisplay();
			}
			return this._createListener(type,caller,listener,args,false);
		}
		return _super.prototype.on.call(this,type,caller,listener,args);
	}

	/**
	*<p>增加事件侦听器，以使侦听器能够接收事件通知，此侦听事件响应一次后则自动移除侦听。</p>
	*<p>如果侦听鼠标事件，则会自动设置自己和父亲节点的属性 mouseEnabled 的值为 true(如果父节点mouseEnabled=false，则停止设置父节点mouseEnabled属性)。</p>
	*@param type 事件的类型。
	*@param caller 事件侦听函数的执行域。
	*@param listener 事件侦听函数。
	*@param args （可选）事件侦听函数的回调参数。
	*@return 此 EventDispatcher 对象。
	*/
	__proto.once=function(type,caller,listener,args){
		if (this._mouseState!==1 && this.isMouseEvent(type)){
			this.mouseEnabled=true;
			this._setBit(0x40,true);
			if (this._parent){
				this._$2__onDisplay();
			}
			return this._createListener(type,caller,listener,args,true);
		}
		return _super.prototype.once.call(this,type,caller,listener,args);
	}

	/**@private */
	__proto._$2__onDisplay=function(){
		if (this._mouseState!==1){
			var ele=this;
			ele=ele.parent;
			while (ele && ele._mouseState!==1){
				if (ele._getBit(0x40))break ;
				ele.mouseEnabled=true;
				ele._setBit(0x40,true);
				ele=ele.parent;
			}
		}
	}

	/**@private */
	__proto._setParent=function(value){
		_super.prototype._setParent.call(this,value);
		if (value && this._getBit(0x40)){
			this._$2__onDisplay();
		}
	}

	/**
	*<p>加载并显示一个图片。相当于加载图片后，设置texture属性</p>
	*<p>注意：2.0改动：多次调用，只会显示一个图片（1.0会显示多个图片）,x,y,width,height参数取消。</p>
	*@param url 图片地址。
	*@param complete （可选）加载完成回调。
	*@return 返回精灵对象本身。
	*/
	__proto.loadImage=function(url,complete){
		var _$this=this;
		var tex=Loader.getRes(url);
		if (!tex){
			tex=new Texture();
			tex.load(url);
			Loader.cacheRes(url,tex);
		}
		this.texture=tex;
		if (!tex.getIsReady())tex.once("ready",null,loaded);
		else loaded();
		function loaded (){
			_$this.repaint(0x03);
			complete && complete.run();
		}
		return this;
	}

	/**cacheAs后，设置自己和父对象缓存失效。*/
	__proto.repaint=function(type){
		(type===void 0)&& (type=0x02);
		if (!(this._repaint&type)){
			this._repaint |=type;
			this.parentRepaint(type);
		}
		if (this._cacheStyle && this._cacheStyle.maskParent){
			this._cacheStyle.maskParent.repaint(type);
		}
	}

	/**
	*@private
	*获取是否重新缓存。
	*@return 如果重新缓存值为 true，否则值为 false。
	*/
	__proto._needRepaint=function(){
		return (this._repaint&0x02)&& this._cacheStyle.enableCanvasRender && this._cacheStyle.reCache;
	}

	/**@private */
	__proto._childChanged=function(child){
		if (this._children.length)this._renderType |=0x2000;
		else this._renderType &=~0x2000;
		this._setRenderType(this._renderType);
		if (child && this._getBit(0x20))Laya.systemTimer.callLater(this,this.updateZOrder);
		this.repaint(0x03);
	}

	/**cacheAs时，设置所有父对象缓存失效。 */
	__proto.parentRepaint=function(type){
		(type===void 0)&& (type=0x02);
		var p=this._parent;
		if (p && !(p._repaint&type)){
			p._repaint |=type;
			p.parentRepaint(type);
		}
	}

	/**@private */
	__proto._setMask=function(value){}
	/**
	*开始拖动此对象。
	*@param area （可选）拖动区域，此区域为当前对象注册点活动区域（不包括对象宽高），可选。
	*@param hasInertia （可选）鼠标松开后，是否还惯性滑动，默认为false，可选。
	*@param elasticDistance （可选）橡皮筋效果的距离值，0为无橡皮筋效果，默认为0，可选。
	*@param elasticBackTime （可选）橡皮筋回弹时间，单位为毫秒，默认为300毫秒，可选。
	*@param data （可选）拖动事件携带的数据，可选。
	*@param disableMouseEvent （可选）禁用其他对象的鼠标检测，默认为false，设置为true能提高性能。
	*@param ratio （可选）惯性阻尼系数，影响惯性力度和时长。
	*/
	__proto.startDrag=function(area,hasInertia,elasticDistance,elasticBackTime,data,disableMouseEvent,ratio){
		(hasInertia===void 0)&& (hasInertia=false);
		(elasticDistance===void 0)&& (elasticDistance=0);
		(elasticBackTime===void 0)&& (elasticBackTime=300);
		(disableMouseEvent===void 0)&& (disableMouseEvent=false);
		(ratio===void 0)&& (ratio=0.92);
		this._style.dragging || (this.getStyle().dragging=new Dragging());
		this._style.dragging.start(this,area,hasInertia,elasticDistance,elasticBackTime,data,disableMouseEvent,ratio);
	}

	/**停止拖动此对象。*/
	__proto.stopDrag=function(){
		this._style.dragging && this._style.dragging.stop();
	}

	/**@private */
	__proto._setDisplay=function(value){
		if (!value){
			if (this._cacheStyle){
				this._cacheStyle.releaseContext();
				this._cacheStyle.releaseFilterCache();
				if (this._cacheStyle.hasGlowFilter){
					this._cacheStyle.hasGlowFilter=false;
				}
			}
		}
		_super.prototype._setDisplay.call(this,value);
	}

	/**
	*检测某个点是否在此对象内。
	*@param x 全局x坐标。
	*@param y 全局y坐标。
	*@return 表示是否在对象内。
	*/
	__proto.hitTestPoint=function(x,y){
		var point=this.globalToLocal(Point.TEMP.setTo(x,y));
		x=point.x;
		y=point.y;
		var rect=this._style.hitArea ? this._style.hitArea :(this._width > 0 && this._height > 0)? Rectangle.TEMP.setTo(0,0,this._width,this._height):this.getSelfBounds();
		return rect.contains(x,y);
	}

	/**获得相对于本对象上的鼠标坐标信息。*/
	__proto.getMousePoint=function(){
		return this.globalToLocal(Point.TEMP.setTo(Laya.stage.mouseX,Laya.stage.mouseY));
	}

	/**@private */
	__proto._setTexture=function(value){}
	/**@private */
	__proto._setRenderType=function(type){}
	/**@private */
	__proto._setTranformChange=function(){
		this._tfChanged=true;
		this._renderType |=0x02
		this._setRenderType(this._renderType);
		this.parentRepaint(0x02);
	}

	/**@private */
	__proto._setBgStyleColor=function(x,y,width,height,fillColor){}
	/**@private */
	__proto._setBorderStyleColor=function(x,y,width,height,fillColor,borderWidth){}
	/**
	*设置是否开启自定义渲染，只有开启自定义渲染，才能使用customRender函数渲染。
	*/
	__getset(0,__proto,'customRenderEnable',null,function(b){
		if (b){
			this._renderType |=0x800;
			this._setRenderType(this._renderType);
			this._setCustomRender();
		}
	});

	//_dataf32[SpriteConst.POSCACHE]=value=="bitmap"?2:(value=="normal"?1:0);
	/**
	*<p>指定显示对象是否缓存为静态图像，cacheAs时，子对象发生变化，会自动重新缓存，同时也可以手动调用reCache方法更新缓存。</p>
	*<p>建议把不经常变化的“复杂内容”缓存为静态图像，能极大提高渲染性能。cacheAs有"none"，"normal"和"bitmap"三个值可选。
	*<li>默认为"none"，不做任何缓存。</li>
	*<li>当值为"normal"时，canvas模式下进行画布缓存，webgl模式下进行命令缓存。</li>
	*<li>当值为"bitmap"时，canvas模式下进行依然是画布缓存，webgl模式下使用renderTarget缓存。</li></p>
	*<p>webgl下renderTarget缓存模式缺点：会额外创建renderTarget对象，增加内存开销，缓存面积有最大2048限制，不断重绘时会增加CPU开销。优点：大幅减少drawcall，渲染性能最高。
	*webgl下命令缓存模式缺点：只会减少节点遍历及命令组织，不会减少drawcall数，性能中等。优点：没有额外内存开销，无需renderTarget支持。</p>
	*/
	__getset(0,__proto,'cacheAs',function(){
		return this._cacheStyle.cacheAs;
		},function(value){
		if (value===this._cacheStyle.userSetCache)return;
		if (Render.isConchApp && value !="bitmap")return;
		this._setCacheAs(value);
		this._getCacheStyle().userSetCache=value;
		this._checkCanvasEnable();
		this.repaint();
	});

	/**
	*获得相对于stage的全局Y轴缩放值（会叠加父亲节点的缩放值）。
	*/
	__getset(0,__proto,'globalScaleY',function(){
		var scale=1;
		var ele=this;
		while (ele){
			if (ele===Laya.stage)break ;
			scale *=ele.scaleY;
			ele=ele.parent;
		}
		return scale;
	});

	/**
	*<p>可以设置一个Rectangle区域作为点击区域，或者设置一个<code>HitArea</code>实例作为点击区域，HitArea内可以设置可点击和不可点击区域。</p>
	*<p>如果不设置hitArea，则根据宽高形成的区域进行碰撞。</p>
	*/
	__getset(0,__proto,'hitArea',function(){
		return this._style.hitArea;
		},function(value){
		this.getStyle().hitArea=value;
	});

	/**设置cacheAs为非空时此值才有效，staticCache=true时，子对象变化时不会自动更新缓存，只能通过调用reCache方法手动刷新。*/
	__getset(0,__proto,'staticCache',function(){
		return this._cacheStyle.staticCache;
		},function(value){
		this._getCacheStyle().staticCache=value;
		if (!value)this.reCache();
	});

	/**
	*<p>对象的显示宽度（以像素为单位）。</p>
	*/
	__getset(0,__proto,'displayWidth',function(){
		return this.width *this.scaleX;
	});

	/**z排序，更改此值，则会按照值的大小对同一容器的所有对象重新排序。值越大，越靠上。默认为0，则根据添加顺序排序。*/
	__getset(0,__proto,'zOrder',function(){
		return this._zOrder;
		},function(value){
		if (this._zOrder !=value){
			this._zOrder=value;
			if (this._parent){
				value && this._parent._setBit(0x20,true);
				Laya.systemTimer.callLater(this._parent,this.updateZOrder);
			}
		}
	});

	/**旋转角度，默认值为0。以角度为单位。*/
	__getset(0,__proto,'rotation',function(){
		return this._style.rotation;
		},function(value){
		var style=this.getStyle();
		if (style.rotation!==value){
			this._setRotation(value);
			this._setTranformChange();
		}
	});

	/**
	*<p>显示对象的宽度，单位为像素，默认为0。</p>
	*<p>此宽度用于鼠标碰撞检测，并不影响显示对象图像大小。需要对显示对象的图像进行缩放，请使用scale、scaleX、scaleY。</p>
	*<p>可以通过getbounds获取显示对象图像的实际宽度。</p>
	*/
	__getset(0,__proto,'width',function(){
		if (!this.autoSize)return this._width || (this.texture?this.texture.width:0);
		if (this.texture)return this.texture.width;
		if (!this._graphics && this._children.length===0)return 0;
		return this.getSelfBounds().width;
		},function(value){
		if (this._width!==value){
			this._width=value;
			this.repaint();
		}
	});

	/**表示显示对象相对于父容器的水平方向坐标值。*/
	__getset(0,__proto,'x',function(){
		return this._x;
		},function(value){
		if (this.destroyed)return;
		if (this._x!==value){
			this._setX(value);
			this.parentRepaint(0x02);
			var p=this._cacheStyle.maskParent;
			if (p){
				p.repaint(0x02);
			}
		}
	});

	/**
	*设置一个Texture实例，并显示此图片（如果之前有其他绘制，则会被清除掉）。
	*等同于graphics.clear();graphics.drawImage()，但性能更高
	*还可以赋值一个图片地址，则会自动加载图片，然后显示
	*/
	__getset(0,__proto,'texture',function(){
		return this._texture;
		},function(value){
		if ((typeof value=='string')){
			this.loadImage(value);
			}else if (this._texture !=value){
			this._texture && this._texture._removeReference();
			this._texture=value;
			value && value._addReference();
			this._setTexture(value);
			if (value)this._renderType |=0x100;
			else this._renderType &=~0x100;
			this._setRenderType(this._renderType);
			this.repaint();
		}
	});

	/**
	*获得相对于stage的全局旋转值（会叠加父亲节点的旋转值）。
	*/
	__getset(0,__proto,'globalRotation',function(){
		var angle=0;
		var ele=this;
		while (ele){
			if (ele===Laya.stage)break ;
			angle+=ele.rotation;
			ele=ele.parent;
		}
		return angle;
	});

	/**表示显示对象相对于父容器的垂直方向坐标值。*/
	__getset(0,__proto,'y',function(){
		return this._y;
		},function(value){
		if (this.destroyed)return;
		if (this._y!==value){
			this._setY(value);
			this.parentRepaint(0x02);
			var p=this._cacheStyle.maskParent;
			if (p){
				p.repaint(0x02);
			}
		}
	});

	/**
	*<p>对象的显示高度（以像素为单位）。</p>
	*/
	__getset(0,__proto,'displayHeight',function(){
		return this.height *this.scaleY;
	});

	/**
	*<p>显示对象的高度，单位为像素，默认为0。</p>
	*<p>此高度用于鼠标碰撞检测，并不影响显示对象图像大小。需要对显示对象的图像进行缩放，请使用scale、scaleX、scaleY。</p>
	*<p>可以通过getbounds获取显示对象图像的实际高度。</p>
	*/
	__getset(0,__proto,'height',function(){
		if (!this.autoSize)return this._height || (this.texture?this.texture.height:0);
		if (this.texture)return this.texture.height;
		if (!this._graphics && this._children.length===0)return 0;
		return this.getSelfBounds().height;
		},function(value){
		if (this._height!==value){
			this._height=value;
			this.repaint();
		}
	});

	/**指定要使用的混合模式。目前只支持"lighter"。*/
	__getset(0,__proto,'blendMode',function(){
		return this._style.blendMode;
		},function(value){
		this._setBlendMode(value);
		this.getStyle().blendMode=value;
		if (value && value !="source-over")this._renderType |=0x04;
		else this._renderType &=~0x04;
		this._setRenderType(this._renderType);
		this.parentRepaint();
	});

	/**X轴缩放值，默认值为1。设置为负数，可以实现水平反转效果，比如scaleX=-1。*/
	__getset(0,__proto,'scaleX',function(){
		return this._style.scaleX;
		},function(value){
		var style=this.getStyle();
		if (style.scaleX!==value){
			this._setScaleX(value);
			this._setTranformChange();
		}
	});

	/**Y轴缩放值，默认值为1。设置为负数，可以实现垂直反转效果，比如scaleX=-1。*/
	__getset(0,__proto,'scaleY',function(){
		return this._style.scaleY;
		},function(value){
		var style=this.getStyle();
		if (style.scaleY!==value){
			this._setScaleY(value);
			this._setTranformChange();
		}
	});

	/**对舞台 <code>stage</code> 的引用。*/
	__getset(0,__proto,'stage',function(){
		return Laya.stage;
	});

	/**水平倾斜角度，默认值为0。以角度为单位。*/
	__getset(0,__proto,'skewX',function(){
		return this._style.skewX;
		},function(value){
		var style=this.getStyle();
		if (style.skewX!==value){
			this._setSkewX(value);
			this._setTranformChange();
		}
	});

	/**
	*<p>显示对象的滚动矩形范围，具有裁剪效果(如果只想限制子对象渲染区域，请使用viewport)</p>
	*<p> srollRect和viewport的区别：<br/>
	*1.srollRect自带裁剪效果，viewport只影响子对象渲染是否渲染，不具有裁剪效果（性能更高）。<br/>
	*2.设置rect的x,y属性均能实现区域滚动效果，但scrollRect会保持0,0点位置不变。</p>
	*/
	__getset(0,__proto,'scrollRect',function(){
		return this._style.scrollRect;
		},function(value){
		this.getStyle().scrollRect=value;
		this._setScrollRect(value);
		this.repaint();
		if (value){
			this._renderType |=0x40;
			}else {
			this._renderType &=~0x40;
		}
		this._setRenderType(this._renderType);
	});

	/**垂直倾斜角度，默认值为0。以角度为单位。*/
	__getset(0,__proto,'skewY',function(){
		return this._style.skewY;
		},function(value){
		var style=this.getStyle();
		if (style.skewY!==value){
			this._setSkewY(value);
			this._setTranformChange();
		}
	});

	/**
	*<p>对象的矩阵信息。通过设置矩阵可以实现节点旋转，缩放，位移效果。</p>
	*<p>矩阵更多信息请参考 <code>Matrix</code></p>
	*/
	__getset(0,__proto,'transform',function(){
		return this._tfChanged ? this._adjustTransform():this._transform;
		},function(value){
		this._tfChanged=false;
		var m=this._transform || (this._transform=this._createTransform());
		value.copyTo(m);
		this._setTransform(m);
		if (value){
			this._x=value.tx;
			this._y=value.ty;
			value.tx=value.ty=0;
		}
		if (value)this._renderType |=0x02;
		else {
			this._renderType &=~0x02;
		}
		this._setRenderType(this._renderType);
		this.parentRepaint();
	});

	/**X轴 轴心点的位置，单位为像素，默认为0。轴心点会影响对象位置，缩放中心，旋转中心。*/
	__getset(0,__proto,'pivotX',function(){
		return this._getPivotX();
		},function(value){
		this._setPivotX(value);
		this.repaint();
	});

	/**Y轴 轴心点的位置，单位为像素，默认为0。轴心点会影响对象位置，缩放中心，旋转中心。*/
	__getset(0,__proto,'pivotY',function(){
		return this._getPivotY();
		},function(value){
		this._setPivotY(value);
		this.repaint();
	});

	/**透明度，值为0-1，默认值为1，表示不透明。更改alpha值会影响drawcall。*/
	__getset(0,__proto,'alpha',function(){
		return this._getAlpha();
		},function(value){
		value=value < 0 ? 0 :(value > 1 ? 1 :value);
		this._setAlpha(value);
	});

	/**表示是否可见，默认为true。如果设置不可见，节点将不被渲染。*/
	__getset(0,__proto,'visible',function(){
		return this._visible;
		},function(value){
		if (this._visible!==value){
			this._visible=value;
			this.parentRepaint(0x03);
		}
	});

	/**绘图对象。封装了绘制位图和矢量图的接口，Sprite所有的绘图操作都通过Graphics来实现的。*/
	__getset(0,__proto,'graphics',function(){
		if (!this._graphics){
			this.graphics=new Graphics();
			this._graphics.autoDestroy=true;
		}
		return this._graphics;
		},function(value){
		if (this._graphics)this._graphics._sp=null;
		this._graphics=value;
		if (value){
			this._setGraphics(value);
			this._renderType |=0x200;
			value._sp=this;
			}else {
			this._renderType &=~0x200;
		}
		this._setRenderType(this._renderType);
		this.repaint();
	});

	/**滤镜集合。可以设置多个滤镜组合。*/
	__getset(0,__proto,'filters',function(){
		return this._cacheStyle.filters;
		},function(value){
		value && value.length===0 && (value=null);
		if (this._cacheStyle.filters==value)return;
		this._getCacheStyle().filters=value ? value.slice():null;
		if (Render.isWebGL || Render.isConchApp){
			if (value && value.length){
				this._setColorFilter(value[0]);
				this._renderType |=0x10;
				}else {
				this._setColorFilter(null);
				this._renderType &=~0x10;
			}
			this._setRenderType(this._renderType);
		}
		if (value && value.length > 0){
			if (!this._getBit(0x10))this._setBitUp(0x10);
			if (!((Render.isWebGL || Render.isConchApp)&& value.length==1 && (((value[0])instanceof laya.filters.ColorFilter )))){
				this._getCacheStyle().cacheForFilters=true;
				this._checkCanvasEnable();
			}
			}else {
			if (this._cacheStyle.cacheForFilters){
				this._cacheStyle.cacheForFilters=false;
				this._checkCanvasEnable();
			}
		}
		this._getCacheStyle().hasGlowFilter=this._isHaveGlowFilter();
		this.repaint();
	});

	/**
	*<p>遮罩，可以设置一个对象(支持位图和矢量图)，根据对象形状进行遮罩显示。</p>
	*<p>【注意】遮罩对象坐标系是相对遮罩对象本身的，和Flash机制不同</p>
	*/
	__getset(0,__proto,'mask',function(){
		return this._cacheStyle.mask;
		},function(value){
		if (value && this.mask && this.mask._cacheStyle.maskParent)return;
		this._getCacheStyle().mask=value;
		this._setMask(value);
		this._checkCanvasEnable();
		if (value){
			value._getCacheStyle().maskParent=this;
			}else {
			if (this.mask){
				this.mask._getCacheStyle().maskParent=null;
			}
		}
		this._renderType |=0x20;
		this._setRenderType(this._renderType);
		this.parentRepaint(0x03);
	});

	/**
	*是否接受鼠标事件。
	*默认为false，如果监听鼠标事件，则会自动设置本对象及父节点的属性 mouseEnable 的值都为 true（如果父节点手动设置为false，则不会更改）。
	**/
	__getset(0,__proto,'mouseEnabled',function(){
		return this._mouseState > 1;
		},function(value){
		this._mouseState=value ? 2 :1;
	});

	/**
	*获得相对于stage的全局X轴缩放值（会叠加父亲节点的缩放值）。
	*/
	__getset(0,__proto,'globalScaleX',function(){
		var scale=1;
		var ele=this;
		while (ele){
			if (ele===Laya.stage)break ;
			scale *=ele.scaleX;
			ele=ele.parent;
		}
		return scale;
	});

	/**
	*返回鼠标在此对象坐标系上的 X 轴坐标信息。
	*/
	__getset(0,__proto,'mouseX',function(){
		return this.getMousePoint().x;
	});

	/**
	*返回鼠标在此对象坐标系上的 Y 轴坐标信息。
	*/
	__getset(0,__proto,'mouseY',function(){
		return this.getMousePoint().y;
	});

	/**
	*<p>视口大小，视口外的子对象，将不被渲染(如果想实现裁剪效果，请使用srollRect)，合理使用能提高渲染性能。比如由一个个小图片拼成的地图块，viewport外面的小图片将不渲染</p>
	*<p>srollRect和viewport的区别：<br/>
	*1. srollRect自带裁剪效果，viewport只影响子对象渲染是否渲染，不具有裁剪效果（性能更高）。<br/>
	*2. 设置rect的x,y属性均能实现区域滚动效果，但scrollRect会保持0,0点位置不变。</p>
	*@default null
	*/
	__getset(0,__proto,'viewport',function(){
		return this._style.viewport;
		},function(value){
		if ((typeof value=='string')){
			var recArr;
			recArr=(value).split(",");
			if (recArr.length > 3){
				value=new Rectangle(parseFloat(recArr[0]),parseFloat(recArr[1]),parseFloat(recArr[2]),parseFloat(recArr[3]));
			}
		}
		this.getStyle().viewport=value;
	});

	Sprite.fromImage=function(url){
		return new Sprite().loadImage(url);
	}

	return Sprite;
})(Node)


//class laya.resource.Bitmap extends laya.resource.Resource
var Bitmap=(function(_super){
	function Bitmap(){
		/**@private */
		//this._width=NaN;
		/**@private */
		//this._height=NaN;
		Bitmap.__super.call(this);
		this._width=-1;
		this._height=-1;
	}

	__class(Bitmap,'laya.resource.Bitmap',_super);
	var __proto=Bitmap.prototype;
	//TODO:coverage
	__proto._getSource=function(){
		throw "Bitmap: must override it.";
	}

	/**
	*获取宽度。
	*/
	__getset(0,__proto,'width',function(){
		return this._width;
	});

	/***
	*获取高度。
	*/
	__getset(0,__proto,'height',function(){
		return this._height;
	});

	return Bitmap;
})(Resource)


//class laya.media.h5audio.AudioSoundChannel extends laya.media.SoundChannel
var AudioSoundChannel=(function(_super){
	function AudioSoundChannel(audio){
		/**
		*播放用的audio标签
		*/
		this._audio=null;
		this._onEnd=null;
		this._resumePlay=null;
		AudioSoundChannel.__super.call(this);
		this._onEnd=Utils.bind(this.__onEnd,this);
		this._resumePlay=Utils.bind(this.__resumePlay,this);
		audio.addEventListener("ended",this._onEnd);
		this._audio=audio;
	}

	__class(AudioSoundChannel,'laya.media.h5audio.AudioSoundChannel',_super);
	var __proto=AudioSoundChannel.prototype;
	__proto.__onEnd=function(){
		if (this.loops==1){
			if (this.completeHandler){
				Laya.systemTimer.once(10,this,this.__runComplete,[this.completeHandler],false);
				this.completeHandler=null;
			}
			this.stop();
			this.event("complete");
			return;
		}
		if (this.loops > 0){
			this.loops--;
		}
		this.startTime=0;
		this.play();
	}

	__proto.__resumePlay=function(){
		if (this._audio)this._audio.removeEventListener("canplay",this._resumePlay);
		if (this.isStopped)return;
		try {
			this._audio.currentTime=this.startTime;
			Browser.container.appendChild(this._audio);
			this._audio.play();
			}catch (e){
			this.event("error");
		}
	}

	/**
	*播放
	*/
	__proto.play=function(){
		this.isStopped=false;
		try {
			this._audio.playbackRate=SoundManager.playbackRate;
			this._audio.currentTime=this.startTime;
			}catch (e){
			this._audio.addEventListener("canplay",this._resumePlay);
			return;
		}
		SoundManager.addChannel(this);
		Browser.container.appendChild(this._audio);
		if("play" in this._audio)
			this._audio.play();
	}

	/**
	*停止播放
	*
	*/
	__proto.stop=function(){
		this.isStopped=true;
		SoundManager.removeChannel(this);
		this.completeHandler=null;
		if (!this._audio)
			return;
		if ("pause" in this._audio)
			if (Render.isConchApp){
			this._audio.stop();
		}
		this._audio.pause();
		this._audio.removeEventListener("ended",this._onEnd);
		this._audio.removeEventListener("canplay",this._resumePlay);
		if (!Browser.onIE){
			if (this._audio!=AudioSound._musicAudio){
				Pool.recover("audio:"+this.url,this._audio);
			}
		}
		Browser.removeElement(this._audio);
		this._audio=null;
	}

	__proto.pause=function(){
		this.isStopped=true;
		SoundManager.removeChannel(this);
		if("pause" in this._audio)
			this._audio.pause();
	}

	__proto.resume=function(){
		if (!this._audio)
			return;
		this.isStopped=false;
		SoundManager.addChannel(this);
		if("play" in this._audio)
			this._audio.play();
	}

	/**
	*当前播放到的位置
	*@return
	*
	*/
	__getset(0,__proto,'position',function(){
		if (!this._audio)
			return 0;
		return this._audio.currentTime;
	});

	/**
	*获取总时间。
	*/
	__getset(0,__proto,'duration',function(){
		if (!this._audio)
			return 0;
		return this._audio.duration;
	});

	/**
	*设置音量
	*@param v
	*
	*/
	/**
	*获取音量
	*@return
	*
	*/
	__getset(0,__proto,'volume',function(){
		if (!this._audio)return 1;
		return this._audio.volume;
		},function(v){
		if (!this._audio)return;
		this._audio.volume=v;
	});

	return AudioSoundChannel;
})(SoundChannel)


//class laya.media.webaudio.WebAudioSoundChannel extends laya.media.SoundChannel
var WebAudioSoundChannel=(function(_super){
	function WebAudioSoundChannel(){
		/**
		*声音原始文件数据
		*/
		this.audioBuffer=null;
		/**
		*gain节点
		*/
		this.gain=null;
		/**
		*播放用的数据
		*/
		this.bufferSource=null;
		/**
		*当前时间
		*/
		this._currentTime=0;
		/**
		*当前音量
		*/
		this._volume=1;
		/**
		*播放开始时的时间戳
		*/
		this._startTime=0;
		this._pauseTime=0;
		this._onPlayEnd=null;
		this.context=WebAudioSound.ctx;
		WebAudioSoundChannel.__super.call(this);
		this._onPlayEnd=Utils.bind(this.__onPlayEnd,this);
		if (this.context["createGain"]){
			this.gain=this.context["createGain"]();
			}else {
			this.gain=this.context["createGainNode"]();
		}
	}

	__class(WebAudioSoundChannel,'laya.media.webaudio.WebAudioSoundChannel',_super);
	var __proto=WebAudioSoundChannel.prototype;
	/**
	*播放声音
	*/
	__proto.play=function(){
		SoundManager.addChannel(this);
		this.isStopped=false;
		this._clearBufferSource();
		if (!this.audioBuffer)return;
		var context=this.context;
		var gain=this.gain;
		var bufferSource=context.createBufferSource();
		this.bufferSource=bufferSource;
		bufferSource.buffer=this.audioBuffer;
		bufferSource.connect(gain);
		if (gain)
			gain.disconnect();
		gain.connect(context.destination);
		bufferSource.onended=this._onPlayEnd;
		if (this.startTime >=this.duration)this.startTime=0;
		this._startTime=Browser.now();
		if (this.gain.gain.setTargetAtTime){
			this.gain.gain.setTargetAtTime(this._volume,this.context.currentTime,0.001);
		}else
		this.gain.gain.value=this._volume;
		if (this.loops==0){
			bufferSource.loop=true;
		}
		if (bufferSource.playbackRate.setTargetAtTime){
			bufferSource.playbackRate.setTargetAtTime(SoundManager.playbackRate,this.context.currentTime,0.001)
		}else
		bufferSource.playbackRate.value=SoundManager.playbackRate;
		bufferSource.start(0,this.startTime);
		this._currentTime=0;
	}

	__proto.__onPlayEnd=function(){
		if (this.loops==1){
			if (this.completeHandler){
				Laya.timer.once(10,this,this.__runComplete,[this.completeHandler],false);
				this.completeHandler=null;
			}
			this.stop();
			this.event("complete");
			return;
		}
		if (this.loops > 0){
			this.loops--;
		}
		this.startTime=0;
		this.play();
	}

	__proto._clearBufferSource=function(){
		if (this.bufferSource){
			var sourceNode=this.bufferSource;
			if (sourceNode.stop){
				sourceNode.stop(0);
				}else {
				sourceNode.noteOff(0);
			}
			sourceNode.disconnect(0);
			sourceNode.onended=null;
			if (!WebAudioSoundChannel._tryCleanFailed)this._tryClearBuffer(sourceNode);
			this.bufferSource=null;
		}
	}

	__proto._tryClearBuffer=function(sourceNode){
		if (!Browser.onMac){
			try{
				sourceNode.buffer=null;
				}catch (e){
				WebAudioSoundChannel._tryCleanFailed=true;
			}
			return;
		}
		try {sourceNode.buffer=WebAudioSound._miniBuffer;}catch (e){WebAudioSoundChannel._tryCleanFailed=true;}
	}

	/**
	*停止播放
	*/
	__proto.stop=function(){
		this._clearBufferSource();
		this.audioBuffer=null;
		if (this.gain)
			this.gain.disconnect();
		this.isStopped=true;
		SoundManager.removeChannel(this);
		this.completeHandler=null;
		if (SoundManager.autoReleaseSound)
			SoundManager.disposeSoundLater(this.url);
	}

	__proto.pause=function(){
		if (!this.isStopped){
			this._pauseTime=this.position;
		}
		this._clearBufferSource();
		if (this.gain)
			this.gain.disconnect();
		this.isStopped=true;
		SoundManager.removeChannel(this);
		if (SoundManager.autoReleaseSound)
			SoundManager.disposeSoundLater(this.url);
	}

	__proto.resume=function(){
		this.startTime=this._pauseTime;
		this.play();
	}

	/**
	*获取当前播放位置
	*/
	__getset(0,__proto,'position',function(){
		if (this.bufferSource){
			return (Browser.now()-this._startTime)/ 1000+this.startTime;
		}
		return 0;
	});

	__getset(0,__proto,'duration',function(){
		if (this.audioBuffer){
			return this.audioBuffer.duration;
		}
		return 0;
	});

	/**
	*设置音量
	*/
	/**
	*获取音量
	*/
	__getset(0,__proto,'volume',function(){
		return this._volume;
		},function(v){
		if (this.isStopped){
			return;
		}
		this._volume=v;
		if (this.gain.gain.setTargetAtTime){
			this.gain.gain.setTargetAtTime(v,this.context.currentTime,0.001);
		}else
		this.gain.gain.value=v;
	});

	WebAudioSoundChannel._tryCleanFailed=false;
	WebAudioSoundChannel.SetTargetDelay=0.001;
	return WebAudioSoundChannel;
})(SoundChannel)


//class laya.wx.mini.MiniSoundChannel extends laya.media.SoundChannel
var MiniSoundChannel=(function(_super){
	function MiniSoundChannel(audio,miniSound){
		/**@private **/
		this._audio=null;
		/**@private **/
		this._onEnd=null;
		/**@private **/
		this._miniSound=null;
		MiniSoundChannel.__super.call(this);
		this._audio=audio;
		this._miniSound=miniSound;
		this._onEnd=MiniSoundChannel.bindToThis(this.__onEnd,this);
		audio.onEnded(this._onEnd);
	}

	__class(MiniSoundChannel,'laya.wx.mini.MiniSoundChannel',_super);
	var __proto=MiniSoundChannel.prototype;
	/**@private **/
	__proto.__onEnd=function(){
		if (this.loops==1){
			if (this.completeHandler){
				Laya.systemTimer.once(10,this,this.__runComplete,[this.completeHandler],false);
				this.completeHandler=null;
			}
			this.stop();
			this.event("complete");
			return;
		}
		if (this.loops > 0){
			this.loops--;
		}
		this.startTime=0;
		this.play();
	}

	/**
	*@private
	*播放
	*/
	__proto.play=function(){
		this.isStopped=false;
		SoundManager.addChannel(this);
		this._audio.play();
	}

	/**
	*@private
	*停止播放
	*
	*/
	__proto.stop=function(){
		this.isStopped=true;
		SoundManager.removeChannel(this);
		this.completeHandler=null;
		if (!this._audio)
			return;
		this._audio.pause();
		this._audio.offEnded(null);
		this._audio=null;
		this._miniSound=null;
		this._onEnd=null;
	}

	/**@private **/
	__proto.pause=function(){
		this.isStopped=true;
		this._audio.pause();
	}

	/**@private **/
	__proto.resume=function(){
		if (!this._audio)
			return;
		this.isStopped=false;
		SoundManager.addChannel(this);
		this._audio.play();
	}

	/**
	*设置开始时间
	*@param time
	*/
	__getset(0,__proto,'startTime',null,function(time){
		if(this._audio){
			this._audio.startTime=time;
		}
	});

	/**@private **/
	/**
	*@private
	*自动播放
	*@param value
	*/
	__getset(0,__proto,'autoplay',function(){
		return this._audio.autoplay;
		},function(value){
		this._audio.autoplay=value;
	});

	/**
	*@private
	*当前播放到的位置
	*@return
	*
	*/
	__getset(0,__proto,'position',function(){
		if (!this._audio)
			return 0;
		return this._audio.currentTime;
	});

	/**
	*@private
	*获取总时间。
	*/
	__getset(0,__proto,'duration',function(){
		if (!this._audio)
			return 0;
		return this._audio.duration;
	});

	/**@private **/
	/**@private **/
	__getset(0,__proto,'loop',function(){
		return this._audio.loop;
		},function(value){
		this._audio.loop=value;
	});

	/**
	*@private
	*设置音量
	*@param v
	*
	*/
	/**
	*@private
	*获取音量
	*@return
	*/
	__getset(0,__proto,'volume',function(){
		if (!this._audio)return 1;
		return this._audio.volume;
		},function(v){
		if (!this._audio)return;
		this._audio.volume=v;
	});

	MiniSoundChannel.bindToThis=function(fun,scope){
		var rst=fun;
		rst=fun.bind(scope);;
		return rst;
	}

	return MiniSoundChannel;
})(SoundChannel)


//class laya.display.Text extends laya.display.Sprite
var Text=(function(_super){
	function Text(){
		/**@private */
		this._clipPoint=null;
		/**@private 表示文本内容字符串。*/
		this._text=null;
		/**@private 表示文本内容是否发生改变。*/
		this._isChanged=false;
		/**@private 表示文本的宽度，以像素为单位。*/
		this._textWidth=0;
		/**@private 表示文本的高度，以像素为单位。*/
		this._textHeight=0;
		/**@private 存储文字行数信息。*/
		this._lines=[];
		/**@private 保存每行宽度*/
		this._lineWidths=[];
		/**@private 文本的内容位置 X 轴信息。*/
		this._startX=0;
		/**@private 文本的内容位置X轴信息。 */
		this._startY=0;
		/**@private */
		this._words=null;
		/**@private */
		this._charSize={};
		/**@private */
		this._valign="top";
		/**@private */
		this._color="#000000";
		Text.__super.call(this);
		this._fontSize=Text.defaultFontSize;
		this._font=Text.defaultFont;
		this.overflow="visible";
		this._style=TextStyle.EMPTY;
	}

	__class(Text,'laya.display.Text',_super);
	var __proto=Text.prototype;
	/**
	*@private
	*获取样式。
	*@return 样式 Style 。
	*/
	__proto.getStyle=function(){
		this._style===TextStyle.EMPTY && (this._style=TextStyle.create());
		return this._style;
	}

	__proto._getTextStyle=function(){
		if (this._style===TextStyle.EMPTY){
			this._style=TextStyle.create();
		}
		return this._style;
	}

	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._clipPoint=null;
		this._lines=null;
		this._lineWidths=null;
		this._words=null;
		this._charSize=null;
	}

	/**
	*@private
	*@inheritDoc
	*/
	__proto._getBoundPointsM=function(ifRotate){
		(ifRotate===void 0)&& (ifRotate=false);
		var rec=Rectangle.TEMP;
		rec.setTo(0,0,this.width,this.height);
		return rec._getBoundPoints();
	}

	/**
	*@inheritDoc
	*/
	__proto.getGraphicBounds=function(realSize){
		(realSize===void 0)&& (realSize=false);
		var rec=Rectangle.TEMP;
		rec.setTo(0,0,this.width,this.height);
		return rec;
	}

	/**
	*@private
	*/
	__proto._getCSSStyle=function(){
		return this._style;
	}

	/**
	*<p>根据指定的文本，从语言包中取当前语言的文本内容。并对此文本中的{i}文本进行替换。</p>
	*<p>设置Text.langPacks语言包后，即可使用lang获取里面的语言</p>
	*<p>例如：
	*<li>（1）text 的值为“我的名字”，先取到这个文本对应的当前语言版本里的值“My name”，将“My name”设置为当前文本的内容。</li>
	*<li>（2）text 的值为“恭喜你赢得{0}个钻石，{1}经验。”，arg1 的值为100，arg2 的值为200。
	*则先取到这个文本对应的当前语言版本里的值“Congratulations on your winning {0}diamonds,{1}experience.”，
	*然后将文本里的{0}、{1}，依据括号里的数字从0开始替换为 arg1、arg2 的值。
	*将替换处理后的文本“Congratulations on your winning 100 diamonds,200 experience.”设置为当前文本的内容。
	*</li>
	*</p>
	*@param text 文本内容。
	*@param ...args 文本替换参数。
	*/
	__proto.lang=function(text,arg1,arg2,arg3,arg4,arg5,arg6,arg7,arg8,arg9,arg10){
		text=Text.langPacks && Text.langPacks[text] ? Text.langPacks[text] :text;
		if (arguments.length < 2){
			this._text=text;
			}else {
			for (var i=0,n=arguments.length;i < n;i++){
				text=text.replace("{"+i+"}",arguments[i+1]);
			}
			this._text=text;
		}
	}

	/**
	*@private
	*/
	__proto._getContextFont=function(){
		return (this.italic ? "italic " :"")+(this.bold ? "bold " :"")+this.fontSize+"px "+(Browser.onIPhone ? (laya.display.Text.fontFamilyMap[this.font] || this.font):this.font);
	}

	/**
	*@private
	*/
	__proto._isPassWordMode=function(){
		var style=this._style;
		var password=style.asPassword;
		if (("prompt" in this)&& this['prompt']==this._text)
			password=false;
		return password;
	}

	/**
	*@private
	*/
	__proto._getPassWordTxt=function(txt){
		var len=txt.length;
		var word;
		word="";
		for (var j=len;j > 0;j--){
			word+="●";
		}
		return word;
	}

	/**
	*@private
	*渲染文字。
	*@param begin 开始渲染的行索引。
	*@param visibleLineCount 渲染的行数。
	*/
	__proto._renderText=function(){
		var padding=this.padding;
		var visibleLineCount=this._lines.length;
		if (this.overflow !="visible"){
			visibleLineCount=Math.min(visibleLineCount,Math.floor((this.height-padding[0]-padding[2])/ (this.leading+this._charSize.height))+1);
		};
		var beginLine=this.scrollY / (this._charSize.height+this.leading)| 0;
		var graphics=this.graphics;
		graphics.clear(true);
		var ctxFont=this._getContextFont();
		Browser.context.font=ctxFont;
		var startX=padding[3];
		var textAlgin="left";
		var lines=this._lines;
		var lineHeight=this.leading+this._charSize.height;
		var tCurrBitmapFont=(this._style).currBitmapFont;
		if (tCurrBitmapFont){
			lineHeight=this.leading+tCurrBitmapFont.getMaxHeight();
		};
		var startY=padding[0];
		if ((!tCurrBitmapFont)&& this._width > 0 && this._textWidth <=this._width){
			if (this.align=="right"){
				textAlgin="right";
				startX=this._width-padding[1];
				}else if (this.align=="center"){
				textAlgin="center";
				startX=this._width *0.5+padding[3]-padding[1];
			}
		}
		if (this._height > 0){
			var tempVAlign=(this._textHeight > this._height)? "top" :this.valign;
			if (tempVAlign==="middle")
				startY=(this._height-visibleLineCount *lineHeight)*0.5+padding[0]-padding[2];
			else if (tempVAlign==="bottom")
			startY=this._height-visibleLineCount *lineHeight-padding[2];
		};
		var style=this._style;
		if (tCurrBitmapFont && tCurrBitmapFont.autoScaleSize){
			var bitmapScale=tCurrBitmapFont.fontSize / this.fontSize;
		}
		if (this._clipPoint){
			graphics.save();
			if (tCurrBitmapFont && tCurrBitmapFont.autoScaleSize){
				var tClipWidth=0;
				var tClipHeight=0;
				this._width ? tClipWidth=(this._width-padding[3]-padding[1]):tClipWidth=this._textWidth;
				this._height ? tClipHeight=(this._height-padding[0]-padding[2]):tClipHeight=this._textHeight;
				tClipWidth *=bitmapScale;
				tClipHeight *=bitmapScale;
				graphics.clipRect(padding[3],padding[0],tClipWidth,tClipHeight);
				}else {
				graphics.clipRect(padding[3],padding[0],this._width ? (this._width-padding[3]-padding[1]):this._textWidth,this._height ? (this._height-padding[0]-padding[2]):this._textHeight);
			}
			this.repaint();
		};
		var password=style.asPassword;
		if (("prompt" in this)&& this['prompt']==this._text)
			password=false;
		var x=0,y=0;
		var end=Math.min(this._lines.length,visibleLineCount+beginLine)|| 1;
		for (var i=beginLine;i < end;i++){
			var word=lines[i];
			var _word;
			if (password){
				var len=word.length;
				word="";
				for (var j=len;j > 0;j--){
					word+="●";
				}
			}
			if (word==null)word="";
			x=startX-(this._clipPoint ? this._clipPoint.x :0);
			y=startY+lineHeight *i-(this._clipPoint ? this._clipPoint.y :0);
			this.underline && this._drawUnderline(textAlgin,x,y,i);
			if (tCurrBitmapFont){
				var tWidth=this.width;
				if (tCurrBitmapFont.autoScaleSize){
					tWidth=this.width *bitmapScale;
				}
				tCurrBitmapFont._drawText(word,this,x,y,this.align,tWidth);
				}else {
				if (Render.isWebGL){
					this._words || (this._words=[]);
					_word=this._words.length > (i-beginLine)? this._words[i-beginLine] :new WordText();
					_word.setText(word);
					}else {
					_word=word;
				}
				style.stroke ? graphics.fillBorderText(_word,x,y,ctxFont,this.color,style.strokeColor,style.stroke,textAlgin):graphics.fillText(_word,x,y,ctxFont,this.color,textAlgin);
			}
		}
		if (tCurrBitmapFont && tCurrBitmapFont.autoScaleSize){
			var tScale=1 / bitmapScale;
			this.scale(tScale,tScale);
		}
		if (this._clipPoint)graphics.restore();
		this._startX=startX;
		this._startY=startY;
	}

	/**
	*@private
	*绘制下划线
	*@param x 本行坐标
	*@param y 本行坐标
	*@param lineIndex 本行索引
	*/
	__proto._drawUnderline=function(align,x,y,lineIndex){
		var lineWidth=this._lineWidths[lineIndex];
		switch (align){
			case 'center':
				x-=lineWidth / 2;
				break ;
			case 'right':
				x-=lineWidth;
				break ;
			case 'left':
			default :
				break ;
			}
		y+=this._charSize.height;
		this._graphics.drawLine(x,y,x+lineWidth,y,this.underlineColor || this.color,1);
	}

	/**
	*<p>排版文本。</p>
	*<p>进行宽高计算，渲染、重绘文本。</p>
	*/
	__proto.typeset=function(){
		this._isChanged=false;
		if (!this._text){
			this._clipPoint=null;
			this._textWidth=this._textHeight=0;
			this.graphics.clear(true);
			return;
		}
		if (Render.isConchApp){
			window.conchTextCanvas.font=this._getContextFont();;
			}else{
			Browser.context.font=this._getContextFont();
		}
		this._lines.length=0;
		this._lineWidths.length=0;
		if (this._isPassWordMode()){
			this._parseLines(this._getPassWordTxt(this._text));
		}else
		this._parseLines(this._text);
		this._evalTextSize();
		if (this._checkEnabledViewportOrNot())this._clipPoint || (this._clipPoint=new Point(0,0));
		else this._clipPoint=null;
		this._renderText();
	}

	/**@private */
	__proto._evalTextSize=function(){
		var nw=NaN,nh=NaN;
		nw=Math.max.apply(this,this._lineWidths);
		if ((this._style).currBitmapFont)
			nh=this._lines.length *((this._style).currBitmapFont.getMaxHeight()+this.leading)+this.padding[0]+this.padding[2];
		else
		nh=this._lines.length *(this._charSize.height+this.leading)+this.padding[0]+this.padding[2];
		if (nw !=this._textWidth || nh !=this._textHeight){
			this._textWidth=nw;
			this._textHeight=nh;
		}
	}

	/**@private */
	__proto._checkEnabledViewportOrNot=function(){
		return this.overflow=="scroll" && ((this._width > 0 && this._textWidth > this._width)|| (this._height > 0 && this._textHeight > this._height));
	}

	/**
	*<p>快速更改显示文本。不进行排版计算，效率较高。</p>
	*<p>如果只更改文字内容，不更改文字样式，建议使用此接口，能提高效率。</p>
	*@param text 文本内容。
	*/
	__proto.changeText=function(text){
		if (this._text!==text){
			this.lang(text+"");
			if (this._graphics && this._graphics.replaceText(this._text)){
				}else {
				this.typeset();
			}
		}
	}

	/**
	*@private
	*分析文本换行。
	*/
	__proto._parseLines=function(text){
		var needWordWrapOrTruncate=this.wordWrap || this.overflow=="hidden";
		if (needWordWrapOrTruncate){
			var wordWrapWidth=this._getWordWrapWidth();
		};
		var bitmapFont=(this._style).currBitmapFont;
		if (bitmapFont){
			this._charSize.width=bitmapFont.getMaxWidth();
			this._charSize.height=bitmapFont.getMaxHeight();
			}else {
			var measureResult=null;
			if (Render.isConchApp){
				measureResult=window.conchTextCanvas.measureText(this._testWord);
				}else {
				measureResult=Browser.context.measureText(Text._testWord);
			}
			this._charSize.width=measureResult.width;
			this._charSize.height=(measureResult.height || this.fontSize);
		};
		var lines=text.replace(/\r\n/g,"\n").split("\n");
		for (var i=0,n=lines.length;i < n;i++){
			var line=lines[i];
			if (needWordWrapOrTruncate)
				this._parseLine(line,wordWrapWidth);
			else {
				this._lineWidths.push(this._getTextWidth(line));
				this._lines.push(line);
			}
		}
	}

	/**
	*@private
	*解析行文本。
	*@param line 某行的文本。
	*@param wordWrapWidth 文本的显示宽度。
	*/
	__proto._parseLine=function(line,wordWrapWidth){
		var ctx=Browser.context;
		var lines=this._lines;
		var maybeIndex=0;
		var execResult;
		var charsWidth=NaN;
		var wordWidth=NaN;
		var startIndex=0;
		charsWidth=this._getTextWidth(line);
		if (charsWidth <=wordWrapWidth){
			lines.push(line);
			this._lineWidths.push(charsWidth);
			return;
		}
		charsWidth=this._charSize.width;
		maybeIndex=Math.floor(wordWrapWidth / charsWidth);
		(maybeIndex==0)&& (maybeIndex=1);
		charsWidth=this._getTextWidth(line.substring(0,maybeIndex));
		wordWidth=charsWidth;
		for (var j=maybeIndex,m=line.length;j < m;j++){
			charsWidth=this._getTextWidth(line.charAt(j));
			wordWidth+=charsWidth;
			if (wordWidth > wordWrapWidth){
				if (this.wordWrap){
					var newLine=line.substring(startIndex,j);
					if (newLine.charCodeAt(newLine.length-1)< 255){
						execResult=/(?:\w|-)+$/.exec(newLine);
						if (execResult){
							j=execResult.index+startIndex;
							if (execResult.index==0)j+=newLine.length;
							else newLine=line.substring(startIndex,j);
						}
					}
					lines.push(newLine);
					this._lineWidths.push(wordWidth-charsWidth);
					startIndex=j;
					if (j+maybeIndex < m){
						j+=maybeIndex;
						charsWidth=this._getTextWidth(line.substring(startIndex,j));
						wordWidth=charsWidth;
						j--;
						}else {
						lines.push(line.substring(startIndex,m));
						this._lineWidths.push(this._getTextWidth(lines[lines.length-1]));
						startIndex=-1;
						break ;
					}
					}else if (this.overflow=="hidden"){
					lines.push(line.substring(0,j));
					this._lineWidths.push(this._getTextWidth(lines[lines.length-1]));
					return;
				}
			}
		}
		if (this.wordWrap && startIndex !=-1){
			lines.push(line.substring(startIndex,m));
			this._lineWidths.push(this._getTextWidth(lines[lines.length-1]));
		}
	}

	/**@private */
	__proto._getTextWidth=function(text){
		var bitmapFont=(this._style).currBitmapFont;
		if (bitmapFont)return bitmapFont.getTextWidth(text);
		else {
			if (Render.isConchApp){
				return window.conchTextCanvas.measureText(text).width;;
			}
			else return Browser.context.measureText(text).width;
		}
	}

	/**
	*@private
	*获取换行所需的宽度。
	*/
	__proto._getWordWrapWidth=function(){
		var p=this.padding;
		var w=NaN;
		var bitmapFont=(this._style).currBitmapFont;
		if (bitmapFont && bitmapFont.autoScaleSize)w=this._width *(bitmapFont.fontSize / this.fontSize);
		else w=this._width;
		if (w <=0){
			w=this.wordWrap ? 100 :Browser.width;
		}
		w <=0 && (w=100);
		return w-p[3]-p[1];
	}

	/**
	*返回字符在本类实例的父坐标系下的坐标。
	*@param charIndex 索引位置。
	*@param out （可选）输出的Point引用。
	*@return Point 字符在本类实例的父坐标系下的坐标。如果out参数不为空，则将结果赋值给指定的Point对象，否则创建一个新的Point对象返回。建议使用Point.TEMP作为out参数，可以省去Point对象创建和垃圾回收的开销，尤其是在需要频繁执行的逻辑中，比如帧循环和MOUSE_MOVE事件回调函数里面。
	*/
	__proto.getCharPoint=function(charIndex,out){
		this._isChanged && Laya.systemTimer.runCallLater(this,this.typeset);
		var len=0,lines=this._lines,startIndex=0;
		for (var i=0,n=lines.length;i < n;i++){
			len+=lines[i].length;
			if (charIndex < len){
				var line=i;
				break ;
			}
			startIndex=len;
		};
		var ctxFont=(this.italic ? "italic " :"")+(this.bold ? "bold " :"")+this.fontSize+"px "+this.font;
		Browser.context.font=ctxFont;
		var width=this._getTextWidth(this._text.substring(startIndex,charIndex));
		var point=out || new Point();
		return point.setTo(this._startX+width-(this._clipPoint ? this._clipPoint.x :0),this._startY+line *(this._charSize.height+this.leading)-(this._clipPoint ? this._clipPoint.y :0));
	}

	/**
	*@inheritDoc
	*/
	__getset(0,__proto,'width',function(){
		if (this._width)return this._width;
		return this.textWidth+this.padding[1]+this.padding[3];
		},function(value){
		if (value !=this._width){
			Laya.superSet(Sprite,this,'width',value);
			this.isChanged=true;
			if (this.borderColor){
				this._setBorderStyleColor(0,0,this.width,this.height,this.borderColor,1);
			}
		}
	});

	/**
	*表示文本的宽度，以像素为单位。
	*/
	__getset(0,__proto,'textWidth',function(){
		this._isChanged && Laya.systemTimer.runCallLater(this,this.typeset);
		return this._textWidth;
	});

	/**
	*@inheritDoc
	*/
	__getset(0,__proto,'height',function(){
		if (this._height)return this._height;
		return this.textHeight;
		},function(value){
		if (value !=this._height){
			Laya.superSet(Sprite,this,'height',value);
			this.isChanged=true;
			if (this.borderColor){
				this._setBorderStyleColor(0,0,this.width,this.height,this.borderColor,1);
			}
		}
	});

	/**
	*表示文本的高度，以像素为单位。
	*/
	__getset(0,__proto,'textHeight',function(){
		this._isChanged && Laya.systemTimer.runCallLater(this,this.typeset);
		return this._textHeight;
	});

	/**
	*<p>边距信息。</p>
	*<p>数据格式：[上边距，右边距，下边距，左边距]（边距以像素为单位）。</p>
	*/
	__getset(0,__proto,'padding',function(){
		return (this._style).padding;
		},function(value){
		this._getTextStyle().padding=value;
		this.isChanged=true;
	});

	/**
	*<p>指定文本是否为粗体字。</p>
	*<p>默认值为 false，这意味着不使用粗体字。如果值为 true，则文本为粗体字。</p>
	*/
	__getset(0,__proto,'bold',function(){
		return (this._style).bold;
		},function(value){
		this._getTextStyle().bold=value;
		this.isChanged=true;
	});

	/**当前文本的内容字符串。*/
	__getset(0,__proto,'text',function(){
		return this._text || "";
		},function(value){
		if (this._text!==value){
			this.lang(value+"");
			this.isChanged=true;
			this.event("change");
			if (this.borderColor){
				this._setBorderStyleColor(0,0,this.width,this.height,this.borderColor,1);
			}
		}
	});

	/**
	*<p>表示文本的颜色值。可以通过 <code>Text.defaultColor</code> 设置默认颜色。</p>
	*<p>默认值为黑色。</p>
	*/
	__getset(0,__proto,'color',function(){
		return this._color;
		},function(value){
		if (this._color !=value){
			this._color=value;
			if (!this._isChanged && this._graphics){
				this._graphics.replaceTextColor(this.color)
				}else {
				this.isChanged=true;
			}
		}
	});

	/**
	*<p>文本的字体名称，以字符串形式表示。</p>
	*<p>默认值为："Arial"，可以通过Text.defaultFont设置默认字体。</p>
	*<p>如果运行时系统找不到设定的字体，则用系统默认的字体渲染文字，从而导致显示异常。(通常电脑上显示正常，在一些移动端因缺少设置的字体而显示异常)。</p>
	*@see laya.display.Text#defaultFont
	*/
	__getset(0,__proto,'font',function(){
		return this._font;
		},function(value){
		if ((this._style).currBitmapFont){
			this._getTextStyle().currBitmapFont=null;
			this.scale(1,1);
		}
		if (Text._bitmapFonts && Text._bitmapFonts[value]){
			this._getTextStyle().currBitmapFont=Text._bitmapFonts[value];
		}
		this._font=value;
		this.isChanged=true;
	});

	/**
	*<p>指定文本的字体大小（以像素为单位）。</p>
	*<p>默认为20像素，可以通过 <code>Text.defaultFontSize</code> 设置默认大小。</p>
	*/
	__getset(0,__proto,'fontSize',function(){
		return this._fontSize;
		},function(value){
		this._fontSize=value;
		this.isChanged=true;
	});

	/**
	*<p>表示使用此文本格式的文本是否为斜体。</p>
	*<p>默认值为 false，这意味着不使用斜体。如果值为 true，则文本为斜体。</p>
	*/
	__getset(0,__proto,'italic',function(){
		return (this._style).italic;
		},function(value){
		this._getTextStyle().italic=value;
		this.isChanged=true;
	});

	/**
	*<p>表示文本的水平显示方式。</p>
	*<p><b>取值：</b>
	*<li>"left"： 居左对齐显示。</li>
	*<li>"center"： 居中对齐显示。</li>
	*<li>"right"： 居右对齐显示。</li>
	*</p>
	*/
	__getset(0,__proto,'align',function(){
		return (this._style).align;
		},function(value){
		this._getTextStyle().align=value;
		this.isChanged=true;
	});

	/**
	*<p>表示文本的垂直显示方式。</p>
	*<p><b>取值：</b>
	*<li>"top"： 居顶部对齐显示。</li>
	*<li>"middle"： 居中对齐显示。</li>
	*<li>"bottom"： 居底部对齐显示。</li>
	*</p>
	*/
	__getset(0,__proto,'valign',function(){
		return this._valign;
		},function(value){
		this._valign=value;
		this.isChanged=true;
	});

	/**
	*<p>表示文本是否自动换行，默认为false。</p>
	*<p>若值为true，则自动换行；否则不自动换行。</p>
	*/
	__getset(0,__proto,'wordWrap',function(){
		return (this._style).wordWrap;
		},function(value){
		this._getTextStyle().wordWrap=value;
		this.isChanged=true;
	});

	/**
	*垂直行间距（以像素为单位）。
	*/
	__getset(0,__proto,'leading',function(){
		return (this._style).leading;
		},function(value){
		this._getTextStyle().leading=value;
		this.isChanged=true;
	});

	/**
	*文本背景颜色，以字符串表示。
	*/
	__getset(0,__proto,'bgColor',function(){
		return (this._style).bgColor;
		},function(value){
		this._getTextStyle().bgColor=value;
		this._renderType |=0x80;
		this._setBgStyleColor(0,0,this.width,this.height,value);
		this._setRenderType(this._renderType);
		this.isChanged=true;
	});

	/**
	*文本边框背景颜色，以字符串表示。
	*/
	__getset(0,__proto,'borderColor',function(){
		return (this._style).borderColor;
		},function(value){
		this._getTextStyle().borderColor=value;
		this._renderType |=0x80;
		this._setBorderStyleColor(0,0,this.width,this.height,value,1);
		this._setRenderType(this._renderType);
		this.isChanged=true;
	});

	/**
	*<p>描边宽度（以像素为单位）。</p>
	*<p>默认值0，表示不描边。</p>
	*/
	__getset(0,__proto,'stroke',function(){
		return (this._style).stroke;
		},function(value){
		this._getTextStyle().stroke=value;
		this.isChanged=true;
	});

	/**
	*<p>描边颜色，以字符串表示。</p>
	*<p>默认值为 "#000000"（黑色）;</p>
	*/
	__getset(0,__proto,'strokeColor',function(){
		return (this._style).strokeColor;
		},function(value){
		this._getTextStyle().strokeColor=value;
		this.isChanged=true;
	});

	/**
	*@private
	*一个布尔值，表示文本的属性是否有改变。若为true表示有改变。
	*/
	__getset(0,__proto,'isChanged',null,function(value){
		if (this._isChanged!==value){
			this._isChanged=value;
			value && Laya.systemTimer.callLater(this,this.typeset);
		}
	});

	/**
	*<p>设置横向滚动量。</p>
	*<p>即使设置超出滚动范围的值，也会被自动限制在可能的最大值处。</p>
	*/
	/**
	*获取横向滚动量。
	*/
	__getset(0,__proto,'scrollX',function(){
		if (!this._clipPoint)return 0;
		return this._clipPoint.x;
		},function(value){
		if (this.overflow !="scroll" || (this.textWidth < this._width || !this._clipPoint))return;
		value=value < this.padding[3] ? this.padding[3] :value;
		var maxScrollX=this._textWidth-this._width;
		value=value > maxScrollX ? maxScrollX :value;
		this._clipPoint.x=value;
		this._renderText();
	});

	/**
	*设置纵向滚动量（px)。即使设置超出滚动范围的值，也会被自动限制在可能的最大值处。
	*/
	/**
	*获取纵向滚动量。
	*/
	__getset(0,__proto,'scrollY',function(){
		if (!this._clipPoint)return 0;
		return this._clipPoint.y;
		},function(value){
		if (this.overflow !="scroll" || (this.textHeight < this._height || !this._clipPoint))return;
		value=value < this.padding[0] ? this.padding[0] :value;
		var maxScrollY=this._textHeight-this._height;
		value=value > maxScrollY ? maxScrollY :value;
		this._clipPoint.y=value;
		this._renderText();
	});

	/**
	*获取横向可滚动最大值。
	*/
	__getset(0,__proto,'maxScrollX',function(){
		return (this.textWidth < this._width)? 0 :this._textWidth-this._width;
	});

	/**
	*获取纵向可滚动最大值。
	*/
	__getset(0,__proto,'maxScrollY',function(){
		return (this.textHeight < this._height)? 0 :this._textHeight-this._height;
	});

	/**返回文字行信息*/
	__getset(0,__proto,'lines',function(){
		if (this._isChanged)this.typeset();
		return this._lines;
	});

	/**下划线的颜色，为null则使用字体颜色。*/
	__getset(0,__proto,'underlineColor',function(){
		return (this._style).underlineColor;
		},function(value){
		this._getTextStyle().underlineColor=value;
		if (!this._isChanged)this._renderText();
	});

	/**是否显示下划线。*/
	__getset(0,__proto,'underline',function(){
		return (this._style).underline;
		},function(value){
		this._getTextStyle().underline=value;
	});

	Text.defaultFontStr=function(){
		return Text.defaultFontSize+"px "+Text.defaultFont;
	}

	Text.registerBitmapFont=function(name,bitmapFont){
		Text._bitmapFonts || (Text._bitmapFonts={});
		Text._bitmapFonts[name]=bitmapFont;
	}

	Text.unregisterBitmapFont=function(name,destroy){
		(destroy===void 0)&& (destroy=true);
		if (Text._bitmapFonts && Text._bitmapFonts[name]){
			var tBitmapFont=Text._bitmapFonts[name];
			if (destroy)tBitmapFont.destroy();
			delete Text._bitmapFonts[name];
		}
	}

	Text.VISIBLE="visible";
	Text.SCROLL="scroll";
	Text.HIDDEN="hidden";
	Text.defaultFontSize=12;
	Text.defaultFont="Arial";
	Text.langPacks=null;
	Text.isComplexText=false;
	Text._testWord="游";
	Text._bitmapFonts=null;
	Text.CharacterCache=true;
	Text.RightToLeft=false;
	__static(Text,
	['fontFamilyMap',function(){return this.fontFamilyMap={"报隶":"报隶-简","黑体":"黑体-简","楷体":"楷体-简","兰亭黑":"兰亭黑-简","隶变":"隶变-简","凌慧体":"凌慧体-简","翩翩体":"翩翩体-简","苹方":"苹方-简","手札体":"手札体-简","宋体":"宋体-简","娃娃体":"娃娃体-简","魏碑":"魏碑-简","行楷":"行楷-简","雅痞":"雅痞-简","圆体":"圆体-简"};}
	]);
	return Text;
})(Sprite)


//class laya.display.AnimationBase extends laya.display.Sprite
var AnimationBase=(function(_super){
	function AnimationBase(){
		/**是否循环播放，调用play(...)方法时，会将此值设置为指定的参数值。*/
		this.loop=false;
		/**播放顺序类型：AnimationBase.WRAP_POSITIVE为正序播放(默认值)，AnimationBase.WRAP_REVERSE为倒序播放，AnimationBase.WRAP_PINGPONG为pingpong播放(当按指定顺序播放完结尾后，如果继续播发，则会改变播放顺序)。*/
		this.wrapMode=0;
		/**@private */
		this._index=0;
		/**@private */
		this._count=0;
		/**@private */
		this._isPlaying=false;
		/**@private */
		this._labels=null;
		/**是否是逆序播放*/
		this._isReverse=false;
		/**@private */
		this._frameRateChanged=false;
		/**@private */
		this._actionName=null;
		/**@private */
		this._controlNode=null;
		AnimationBase.__super.call(this);
		this._interval=Config.animationInterval;
		this._setBitUp(0x10);
	}

	__class(AnimationBase,'laya.display.AnimationBase',_super);
	var __proto=AnimationBase.prototype;
	/**
	*<p>开始播放动画。play(...)方法被设计为在创建实例后的任何时候都可以被调用，当相应的资源加载完毕、调用动画帧填充方法(set frames)或者将实例显示在舞台上时，会判断是否正在播放中，如果是，则进行播放。</p>
	*<p>配合wrapMode属性，可设置动画播放顺序类型。</p>
	*@param start （可选）指定动画播放开始的索引(int)或帧标签(String)。帧标签可以通过addLabel(...)和removeLabel(...)进行添加和删除。
	*@param loop （可选）是否循环播放。
	*@param name （可选）动画名称。
	*/
	__proto.play=function(start,loop,name){
		(start===void 0)&& (start=0);
		(loop===void 0)&& (loop=true);
		(name===void 0)&& (name="");
		this._isPlaying=true;
		this._actionName=name;
		this.index=((typeof start=='string'))? this._getFrameByLabel(start):start;
		this.loop=loop;
		this._isReverse=this.wrapMode===1;
		if (this.interval > 0)this.timerLoop(this.interval,this,this._frameLoop,null,true,true);
	}

	/**@private */
	__proto._getFrameByLabel=function(label){
		for (var i=0;i < this._count;i++){
			var item=this._labels[i];
			if (item && (item).indexOf(label)>-1)return i;
		}
		return 0;
	}

	/**@private */
	__proto._frameLoop=function(){
		if (this._isReverse){
			this._index--;
			if (this._index < 0){
				if (this.loop){
					if (this.wrapMode==2){
						this._index=this._count > 0 ? 1 :0;
						this._isReverse=false;
						}else {
						this._index=this._count-1;
					}
					this.event("complete");
					}else {
					this._index=0;
					this.stop();
					this.event("complete");
					return;
				}
			}
			}else {
			this._index++;
			if (this._index >=this._count){
				if (this.loop){
					if (this.wrapMode==2){
						this._index=this._count-2 >=0 ? this._count-2 :0;
						this._isReverse=true;
						}else {
						this._index=0;
					}
					this.event("complete");
					}else {
					this._index--;
					this.stop();
					this.event("complete");
					return;
				}
			}
		}
		this.index=this._index;
	}

	/**@private */
	__proto._setControlNode=function(node){
		if (this._controlNode){
			this._controlNode.off("display",this,this._resumePlay);
			this._controlNode.off("undisplay",this,this._resumePlay);
		}
		this._controlNode=node;
		if (node && node !=this){
			node.on("display",this,this._resumePlay);
			node.on("undisplay",this,this._resumePlay);
		}
	}

	/**@private */
	__proto._setDisplay=function(value){
		_super.prototype._setDisplay.call(this,value);
		this._resumePlay();
	}

	/**@private */
	__proto._resumePlay=function(){
		if (this._isPlaying){
			if (this._controlNode.displayedInStage)this.play(this._index,this.loop,this._actionName);
			else this.clearTimer(this,this._frameLoop);
		}
	}

	/**
	*停止动画播放。
	*/
	__proto.stop=function(){
		this._isPlaying=false;
		this.clearTimer(this,this._frameLoop);
	}

	/**
	*增加一个帧标签到指定索引的帧上。当动画播放到此索引的帧时会派发Event.LABEL事件，派发事件是在完成当前帧画面更新之后。
	*@param label 帧标签名称
	*@param index 帧索引
	*/
	__proto.addLabel=function(label,index){
		if (!this._labels)this._labels={};
		if (!this._labels[index])this._labels[index]=[];
		this._labels[index].push(label);
	}

	/**
	*删除指定的帧标签。
	*@param label 帧标签名称。注意：如果为空，则删除所有帧标签！
	*/
	__proto.removeLabel=function(label){
		if (!label)this._labels=null;
		else if (this._labels){
			for (var name in this._labels){
				this._removeLabelFromList(this._labels[name],label);
			}
		}
	}

	/**@private */
	__proto._removeLabelFromList=function(list,label){
		if (!list)return;
		for (var i=list.length-1;i >=0;i--){
			if (list[i]==label){
				list.splice(i,1);
			}
		}
	}

	/**
	*将动画切换到指定帧并停在那里。
	*@param position 帧索引或帧标签
	*/
	__proto.gotoAndStop=function(position){
		this.index=((typeof position=='string'))? this._getFrameByLabel(position):position;
		this.stop();
	}

	/**
	*@private
	*显示到某帧
	*@param value 帧索引
	*/
	__proto._displayToIndex=function(value){}
	/**
	*停止动画播放，并清理对象属性。之后可存入对象池，方便对象复用。
	*@return 返回对象本身
	*/
	__proto.clear=function(){
		this.stop();
		this._labels=null;
		return this;
	}

	/**
	*<p>动画播放的帧间隔时间(单位：毫秒)。默认值依赖于Config.animationInterval=50，通过Config.animationInterval可以修改默认帧间隔时间。</p>
	*<p>要想为某动画设置独立的帧间隔时间，可以使用set interval，注意：如果动画正在播放，设置后会重置帧循环定时器的起始时间为当前时间，也就是说，如果频繁设置interval，会导致动画帧更新的时间间隔会比预想的要慢，甚至不更新。</p>
	*/
	__getset(0,__proto,'interval',function(){
		return this._interval;
		},function(value){
		if (this._interval !=value){
			this._frameRateChanged=true;
			this._interval=value;
			if (this._isPlaying && value > 0){
				this.timerLoop(value,this,this._frameLoop,null,true,true);
			}
		}
	});

	/**
	*是否正在播放中。
	*/
	__getset(0,__proto,'isPlaying',function(){
		return this._isPlaying;
	});

	/**
	*动画当前帧的索引。
	*/
	__getset(0,__proto,'index',function(){
		return this._index;
		},function(value){
		this._index=value;
		this._displayToIndex(value);
		if (this._labels && this._labels[value]){
			var tArr=this._labels[value];
			for (var i=0,len=tArr.length;i < len;i++){
				this.event("label",tArr[i]);
			}
		}
	});

	/**
	*当前动画中帧的总数。
	*/
	__getset(0,__proto,'count',function(){
		return this._count;
	});

	AnimationBase.WRAP_POSITIVE=0;
	AnimationBase.WRAP_REVERSE=1;
	AnimationBase.WRAP_PINGPONG=2;
	return AnimationBase;
})(Sprite)


//class laya.display.Scene extends laya.display.Sprite
var Scene=(function(_super){
	function Scene(){
		/**场景被关闭后，是否自动销毁（销毁节点和使用到的资源），默认为false*/
		this.autoDestroyAtClosed=false;
		/**场景地址*/
		this.url=null;
		/**场景时钟*/
		this._timer=null;
		/**@private */
		this._viewCreated=false;
		/**@private */
		this._idMap=null;
		/**@private */
		this._$componentType="Scene";
		Scene.__super.call(this);
		this._setBit(0x08,true);
		Scene.unDestroyedScenes.push(this);
		this._scene=this;
		this.createChildren();
	}

	__class(Scene,'laya.display.Scene',_super);
	var __proto=Scene.prototype;
	/**
	*@private 兼容老项目
	*/
	__proto.createChildren=function(){}
	/**
	*@private 兼容老项目
	*装载场景视图。用于加载模式。
	*@param path 场景地址。
	*/
	__proto.loadScene=function(path){
		var url=path.indexOf(".")>-1 ? path :path+".scene";
		var view=Laya.loader.getRes(url);
		if (view){
			this.createView(view);
			}else {
			Laya.loader.load(url,Handler.create(this,this.createView),null,"json");
		}
	}

	/**
	*@private 兼容老项目
	*通过视图数据创建视图。
	*@param uiView 视图数据信息。
	*/
	__proto.createView=function(view){
		if (view && !this._viewCreated){
			this._viewCreated=true;
			SceneUtils.createByData(this,view);
		}
	}

	/**
	*根据IDE内的节点id，获得节点实例
	*/
	__proto.getNodeByID=function(id){
		if (this._idMap)return this._idMap[id];
		return null;
	}

	/**
	*打开场景。【注意】被关闭的场景，如果没有设置autoDestroyAtRemoved=true，则资源可能不能被回收，需要自己手动回收
	*@param closeOther 是否关闭其他场景，默认为true（可选）
	*/
	__proto.open=function(closeOther){
		(closeOther===void 0)&& (closeOther=true);
		if (closeOther)Scene.closeAll();
		Scene.root.addChild(this.scene);
		this.onOpened();
	}

	/**场景打开完成后，调用此方法（如果有弹出动画，则在动画完成后执行）*/
	__proto.onOpened=function(){}
	/**
	*关闭场景
	*【注意】被关闭的场景，如果没有设置autoDestroyAtRemoved=true，则资源可能不能被回收，需要自己手动回收
	*/
	__proto.close=function(){
		if (this.autoDestroyAtClosed)this.destroy();
		else this.removeSelf();
		this.onClosed();
	}

	/**关闭完成后，调用此方法（如果有关闭动画，则在动画完成后执行）
	*@param type 如果是点击默认关闭按钮触发，则传入关闭按钮的名字(name)，否则为null。
	*/
	__proto.onClosed=function(type){
		console.log("onClosed");
	}

	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		this._idMap=null;
		_super.prototype.destroy.call(this,destroyChild);
		var list=laya.display.Scene.unDestroyedScenes;
		for (var i=0,n=list.length;i < n;i++){
			if (list[i]===this){
				list.splice(i,1);
				return;
			}
		}
	}

	/**@private */
	__proto._sizeChanged=function(){
		this.event("resize");
	}

	/**@inheritDoc */
	__getset(0,__proto,'scaleX',_super.prototype._$get_scaleX,function(value){
		if (Laya.superGet(Sprite,this,'scaleX')==value)return;
		Laya.superSet(Sprite,this,'scaleX',value);
		this.event("resize");
	});

	/**@inheritDoc */
	__getset(0,__proto,'scaleY',_super.prototype._$get_scaleY,function(value){
		if (Laya.superGet(Sprite,this,'scaleY')==value)return;
		Laya.superSet(Sprite,this,'scaleY',value);
		this.event("resize");
	});

	/**@inheritDoc */
	/**@inheritDoc */
	__getset(0,__proto,'width',function(){
		if (this._width)return this._width;
		var max=0;
		for (var i=this.numChildren-1;i >-1;i--){
			var comp=this.getChildAt(i);
			if (comp._visible){
				max=Math.max(comp._x+comp.width *comp.scaleX,max);
			}
		}
		return max;
		},function(value){
		if (Laya.superGet(Sprite,this,'width')==value)return;
		Laya.superSet(Sprite,this,'width',value);
		this.callLater(this._sizeChanged);
	});

	/**场景时钟*/
	__getset(0,__proto,'timer',function(){
		return this._timer || Laya.timer;
		},function(value){
		this._timer=value;
	});

	/**@inheritDoc */
	/**@inheritDoc */
	__getset(0,__proto,'height',function(){
		if (this._height)return this._height;
		var max=0;
		for (var i=this.numChildren-1;i >-1;i--){
			var comp=this.getChildAt(i);
			if (comp._visible){
				max=Math.max(comp._y+comp.height *comp.scaleY,max);
			}
		}
		return max;
		},function(value){
		if (Laya.superGet(Sprite,this,'height')==value)return;
		Laya.superSet(Sprite,this,'height',value);
		this.callLater(this._sizeChanged);
	});

	/**获取场景根容器*/
	__getset(1,Scene,'root',function(){
		if (!Scene._root){
			Scene._root=Laya.stage.addChild(new Sprite());
			Scene._root.name="root";
			Laya.stage.on("resize",null,resize);
			function resize (){
				Scene._root.size(Laya.stage.width,Laya.stage.height);
				Scene._root.event("resize");
			}
			resize();
		}
		return Scene._root;
	},laya.display.Sprite._$SET_root);

	Scene.load=function(url,complete){
		Laya.loader.resetProgress();
		var loader=new SceneLoader();
		loader.on("complete",null,create);
		loader.load(url);
		function create (){
			var obj=Loader.getRes(url);
			if (!obj)throw "Can not find scene:"+url;
			var runtime=(obj.props && obj.props.runtime)? obj.props.runtime :obj.type;
			var scene=ClassUtils.getInstance(runtime);
			if (scene && (scene instanceof laya.display.Node )){
				scene.url=url;
				if (!scene._getBit(0x08))complete.runWith(scene);
				else {
					scene.on("onViewCreated",null,function(){
						complete && complete.runWith(scene)
					})
					scene.createView(obj);
				}
				}else {
				throw "Can not find scene:"+runtime;
			}
		}
	}

	Scene.open=function(url,closeOther,complete){
		(closeOther===void 0)&& (closeOther=true);
		Scene.load(url,Handler.create(null,Scene._onSceneLoaded,[closeOther,complete]));
	}

	Scene._onSceneLoaded=function(closeOther,complete,scene){
		scene.open(closeOther);
		if (complete)complete.runWith(scene);
	}

	Scene.close=function(url,name){
		(name===void 0)&& (name="");
		var flag=false;
		var list=laya.display.Scene.unDestroyedScenes;
		for (var i=0,n=list.length;i < n;i++){
			var scene=list[i];
			if (scene.parent && scene.url===url && scene.name==name){
				scene.close();
				flag=true;
			}
		}
		return flag;
	}

	Scene.closeAll=function(){
		var root=laya.display.Scene.root;
		for (var i=0,n=root.numChildren;i < n;i++){
			var scene=root.getChildAt(0);
			if ((scene instanceof laya.display.Scene ))scene.close();
		}
	}

	Scene.destroy=function(url,name){
		(name===void 0)&& (name="");
		var flag=false;
		var list=laya.display.Scene.unDestroyedScenes;
		for (var i=0,n=list.length;i < n;i++){
			var scene=list[i];
			if (scene.url===url && scene.name==name){
				scene.destroy();
				flag=true;
			}
		}
		return flag;
	}

	Scene.gc=function(group){
		Resource.destroyUnusedResources(group);
	}

	Scene.unDestroyedScenes=[];
	Scene._root=null;
	return Scene;
})(Sprite)


//class laya.display.Stage extends laya.display.Sprite
var Stage=(function(_super){
	function Stage(){
		/**当前焦点对象，此对象会影响当前键盘事件的派发主体。*/
		this.focus=null;
		/**帧率类型，支持三种模式：fast-60帧(默认)，slow-30帧，mouse-30帧（鼠标活动后会自动加速到60，鼠标不动2秒后降低为30帧，以节省消耗），sleep-1帧。*/
		this._frameRate="fast";
		/**设计宽度（初始化时设置的宽度Laya.init(width,height)）*/
		this.designWidth=0;
		/**设计高度（初始化时设置的高度Laya.init(width,height)）*/
		this.designHeight=0;
		/**画布是否发生翻转。*/
		this.canvasRotation=false;
		/**画布的旋转角度。*/
		this.canvasDegree=0;
		/**
		*<p>设置是否渲染，设置为false，可以停止渲染，画面会停留到最后一次渲染上，减少cpu消耗，此设置不影响时钟。</p>
		*<p>比如非激活状态，可以设置renderingEnabled=false以节省消耗。</p>
		**/
		this.renderingEnabled=true;
		/**是否启用屏幕适配，可以适配后，在某个时候关闭屏幕适配，防止某些操作导致的屏幕意外改变*/
		this.screenAdaptationEnabled=true;
		/**@private */
		this._screenMode="none";
		/**@private */
		this._scaleMode="noscale";
		/**@private */
		this._alignV="top";
		/**@private */
		this._alignH="left";
		/**@private */
		this._bgColor="black";
		/**@private */
		this._mouseMoveTime=0;
		/**@private */
		this._renderCount=0;
		/**@private */
		this._safariOffsetY=0;
		/**@private */
		this._frameStartTime=NaN;
		/**@private */
		this._isFocused=false;
		/**@private */
		this._isVisibility=false;
		/**@private webgl Color*/
		this._wgColor=[0,0,0,1];
		Stage.__super.call(this);
		this.offset=new Point();
		this._canvasTransform=new Matrix();
		this._previousOrientation=Browser.window.orientation;
		var _$this=this;
		this.transform=Matrix.create();
		this.mouseEnabled=true;
		this.hitTestPrior=true;
		this.autoSize=false;
		this._setBit(0x80,true);
		this._setBit(0x02,true);
		this._isFocused=true;
		this._isVisibility=true;
		var window=Browser.window;
		var _me=this;
		window.addEventListener("focus",function(){
			_$this._isFocused=true;
			_me.event("focus");
			_me.event("focuschange");
		});
		window.addEventListener("blur",function(){
			_$this._isFocused=false;
			_me.event("blur");
			_me.event("focuschange");
			if (_me._isInputting())Input["inputElement"].target.focus=false;
		});
		var hidden="hidden",state="visibilityState",visibilityChange="visibilitychange";
		var document=window.document;
		if (typeof document.hidden!=="undefined"){
			visibilityChange="visibilitychange";
			state="visibilityState";
			}else if (typeof document.mozHidden!=="undefined"){
			visibilityChange="mozvisibilitychange";
			state="mozVisibilityState";
			}else if (typeof document.msHidden!=="undefined"){
			visibilityChange="msvisibilitychange";
			state="msVisibilityState";
			}else if (typeof document.webkitHidden!=="undefined"){
			visibilityChange="webkitvisibilitychange";
			state="webkitVisibilityState";
		}
		window.document.addEventListener(visibilityChange,visibleChangeFun);
		function visibleChangeFun (){
			if (Browser.document[state]=="hidden"){
				_$this._isVisibility=false;
				if (_me._isInputting())Input["inputElement"].target.focus=false;
				}else {
				_$this._isVisibility=true;
			}
			_$this.renderingEnabled=_$this._isVisibility;
			_me.event("visibilitychange");
		}
		window.addEventListener("resize",function(){
			var orientation=Browser.window.orientation;
			if (orientation !=null && orientation !=_$this._previousOrientation && _me._isInputting()){
				Input["inputElement"].target.focus=false;
			}
			_$this._previousOrientation=orientation;
			if (_me._isInputting())return;
			if (Browser.onSafari)
				_me._safariOffsetY=(Browser.window.__innerHeight || Browser.document.body.clientHeight || Browser.document.documentElement.clientHeight)-Browser.window.innerHeight;
			_me._resetCanvas();
		});
		window.addEventListener("orientationchange",function(e){
			_me._resetCanvas();
		});
		this.on("mousemove",this,this._onmouseMove);
		if (Browser.onMobile)this.on("mousedown",this,this._onmouseMove);
	}

	__class(Stage,'laya.display.Stage',_super);
	var __proto=Stage.prototype;
	/**
	*@private
	*在移动端输入时，输入法弹出期间不进行画布尺寸重置。
	*/
	__proto._isInputting=function(){
		return (Browser.onMobile && Input.isInputting);
	}

	/**@private */
	__proto._changeCanvasSize=function(){
		this.setScreenSize(Browser.clientWidth *Browser.pixelRatio,Browser.clientHeight *Browser.pixelRatio);
	}

	/**@private */
	__proto._resetCanvas=function(){
		if (!this.screenAdaptationEnabled)return;
		this._changeCanvasSize();
	}

	/**
	*设置屏幕大小，场景会根据屏幕大小进行适配。可以动态调用此方法，来更改游戏显示的大小。
	*@param screenWidth 屏幕宽度。
	*@param screenHeight 屏幕高度。
	*/
	__proto.setScreenSize=function(screenWidth,screenHeight){
		var rotation=false;
		if (this._screenMode!=="none"){
			var screenType=screenWidth / screenHeight < 1 ? "vertical" :"horizontal";
			rotation=screenType!==this._screenMode;
			if (rotation){
				var temp=screenHeight;
				screenHeight=screenWidth;
				screenWidth=temp;
			}
		}
		this.canvasRotation=rotation;
		var canvas=Render._mainCanvas;
		var canvasStyle=canvas.source.style;
		var mat=this._canvasTransform.identity();
		var scaleMode=this._scaleMode;
		var scaleX=screenWidth / this.designWidth;
		var scaleY=screenHeight / this.designHeight;
		var canvasWidth=this.designWidth;
		var canvasHeight=this.designHeight;
		var realWidth=screenWidth;
		var realHeight=screenHeight;
		var pixelRatio=Browser.pixelRatio;
		this._width=this.designWidth;
		this._height=this.designHeight;
		switch (scaleMode){
			case "noscale":
				scaleX=scaleY=1;
				realWidth=this.designWidth;
				realHeight=this.designHeight;
				break ;
			case "showall":
				scaleX=scaleY=Math.min(scaleX,scaleY);
				canvasWidth=realWidth=Math.round(this.designWidth *scaleX);
				canvasHeight=realHeight=Math.round(this.designHeight *scaleY);
				break ;
			case "noborder":
				scaleX=scaleY=Math.max(scaleX,scaleY);
				realWidth=Math.round(this.designWidth *scaleX);
				realHeight=Math.round(this.designHeight *scaleY);
				break ;
			case "full":
				scaleX=scaleY=1;
				this._width=canvasWidth=screenWidth;
				this._height=canvasHeight=screenHeight;
				break ;
			case "fixedwidth":
				scaleY=scaleX;
				this._height=canvasHeight=Math.round(screenHeight / scaleX);
				break ;
			case "fixedheight":
				scaleX=scaleY;
				this._width=canvasWidth=Math.round(screenWidth / scaleY);
				break ;
			case "fixedauto":
				if ((screenWidth / screenHeight)< (this.designWidth / this.designHeight)){
					scaleY=scaleX;
					this._height=canvasHeight=Math.round(screenHeight / scaleX);
					}else {
					scaleX=scaleY;
					this._width=canvasWidth=Math.round(screenWidth / scaleY);
				}
				break ;
			}
		scaleX *=this.scaleX;
		scaleY *=this.scaleY;
		if (scaleX===1 && scaleY===1){
			this.transform.identity();
			}else {
			this.transform.a=this._formatData(scaleX / (realWidth / canvasWidth));
			this.transform.d=this._formatData(scaleY / (realHeight / canvasHeight));
		}
		if (Render.isConchApp){
			this._conchData._float32Data[10]=this._formatData(scaleX / (realWidth / canvasWidth));
			this._conchData._float32Data[11]=this._formatData(scaleY / (realHeight / canvasHeight));
			this._conchData._float32Data[15]=1;
		}
		canvas.size(canvasWidth,canvasHeight);
		RunDriver.changeWebGLSize(canvasWidth,canvasHeight);
		mat.scale(realWidth / canvasWidth / pixelRatio,realHeight / canvasHeight / pixelRatio);
		if (this._alignH==="left")this.offset.x=0;
		else if (this._alignH==="right")this.offset.x=screenWidth-realWidth;
		else this.offset.x=(screenWidth-realWidth)*0.5 / pixelRatio;
		if (this._alignV==="top")this.offset.y=0;
		else if (this._alignV==="bottom")this.offset.y=screenHeight-realHeight;
		else this.offset.y=(screenHeight-realHeight)*0.5 / pixelRatio;
		this.offset.x=Math.round(this.offset.x);
		this.offset.y=Math.round(this.offset.y);
		mat.translate(this.offset.x,this.offset.y);
		if (this._safariOffsetY)mat.translate(0,this._safariOffsetY);
		this.canvasDegree=0;
		if (rotation){
			if (this._screenMode==="horizontal"){
				mat.rotate(Math.PI / 2);
				mat.translate(screenHeight / pixelRatio,0);
				this.canvasDegree=90;
				}else {
				mat.rotate(-Math.PI / 2);
				mat.translate(0,screenWidth / pixelRatio);
				this.canvasDegree=-90;
			}
		}
		mat.a=this._formatData(mat.a);
		mat.d=this._formatData(mat.d);
		mat.tx=this._formatData(mat.tx);
		mat.ty=this._formatData(mat.ty);
		canvasStyle.transformOrigin=canvasStyle.webkitTransformOrigin=canvasStyle.msTransformOrigin=canvasStyle.mozTransformOrigin=canvasStyle.oTransformOrigin="0px 0px 0px";
		canvasStyle.transform=canvasStyle.webkitTransform=canvasStyle.msTransform=canvasStyle.mozTransform=canvasStyle.oTransform="matrix("+mat.toString()+")";
		if (this._safariOffsetY)mat.translate(0,-this._safariOffsetY);
		mat.translate(parseInt(canvasStyle.left)|| 0,parseInt(canvasStyle.top)|| 0);
		this.visible=true;
		this._repaint |=0x02;
		this.event("resize");
	}

	/**@private */
	__proto._formatData=function(value){
		if (Math.abs(value)< 0.000001)return 0;
		if (Math.abs(1-value)< 0.001)return value > 0 ? 1 :-1;
		return value;
	}

	/**@inheritDoc */
	__proto.getMousePoint=function(){
		return Point.TEMP.setTo(this.mouseX,this.mouseY);
	}

	/**@inheritDoc */
	__proto.repaint=function(type){
		(type===void 0)&& (type=0x02);
		this._repaint |=type;
	}

	/**@inheritDoc */
	__proto.repaintForNative=function(type){
		(type===void 0)&& (type=0x02);
		this._conchData._int32Data[4] |=type;
	}

	/**@inheritDoc */
	__proto.parentRepaint=function(type){
		(type===void 0)&& (type=0x02);
	}

	/**@private */
	__proto._loop=function(){
		this.render(Render._context,0,0);
		return true;
	}

	/**@private */
	__proto.getFrameTm=function(){
		return this._frameStartTime;
	}

	/**@private */
	__proto._onmouseMove=function(e){
		this._mouseMoveTime=Browser.now();
	}

	/**
	*<p>获得距当前帧开始后，过了多少时间，单位为毫秒。</p>
	*<p>可以用来判断函数内时间消耗，通过合理控制每帧函数处理消耗时长，避免一帧做事情太多，对复杂计算分帧处理，能有效降低帧率波动。</p>
	*/
	__proto.getTimeFromFrameStart=function(){
		return Browser.now()-this._frameStartTime;
	}

	/**@inheritDoc */
	__proto.render=function(context,x,y){
		if (this._frameRate==="sleep"){
			var now=Browser.now();
			if (now-this._frameStartTime >=1000)this._frameStartTime=now;
			else return;
		}
		this._renderCount++;
		if (!this._visible){
			if (this._renderCount % 5===0){
				CallLater.I._update();
				Stat.loopCount++;
				Laya.systemTimer._update();
				Laya.startTimer._update();
				Laya.physicsTimer._update();
				Laya.updateTimer._update();
				Laya.lateTimer._update();
				Laya.timer._update();
			}
			return;
		}
		this._frameStartTime=Browser.now();
		var frameMode=this._frameRate==="mouse" ? (((this._frameStartTime-this._mouseMoveTime)< 2000)? "fast" :"slow"):this._frameRate;
		var isFastMode=(frameMode!=="slow");
		var isDoubleLoop=(this._renderCount % 2===0);
		Stat.renderSlow=!isFastMode;
		if (isFastMode || isDoubleLoop){
			CallLater.I._update();
			Stat.loopCount++;
			if (!Render.isConchApp){
				if (Render.isWebGL && this.renderingEnabled){
					context.clear();
					_super.prototype.render.call(this,context,x,y);
					Stat._show && Stat._sp && Stat._sp.render(context,x,y);
				}
			}
		}
		if (this.renderingEnabled && (isFastMode || !isDoubleLoop)){
			if (Render.isWebGL){
				RunDriver.clear(this._bgColor);
				context.flush();
				VectorGraphManager.instance && VectorGraphManager.getInstance().endDispose();
				}else {
				RunDriver.clear(this._bgColor);
				_super.prototype.render.call(this,context,x,y);
				Stat._show && Stat._sp && Stat._sp.render(context,x,y);
				if (Render.isConchApp)context.gl.commit();
			}
		}
		Laya.systemTimer._update();
		Laya.startTimer._update();
		Laya.physicsTimer._update();
		Laya.updateTimer._update();
		Laya.lateTimer._update();
		Laya.timer._update();
	}

	__proto.renderToNative=function(context,x,y){
		this._renderCount++;
		Stat.loopCount++;
		if (!this._visible){
			if (this._renderCount % 5===0){
				CallLater.I._update();
				Stat.loopCount++;
				Laya.systemTimer._update();
				Laya.startTimer._update();
				Laya.physicsTimer._update();
				Laya.updateTimer._update();
				Laya.lateTimer._update();
				Laya.timer._update();
			}
			return;
		}
		CallLater.I._update();
		Laya.systemTimer._update();
		Laya.startTimer._update();
		Laya.physicsTimer._update();
		Laya.updateTimer._update();
		Laya.lateTimer._update();
		Laya.timer._update();
		if (this.renderingEnabled){
			RunDriver.clear(this._bgColor);
			_super.prototype.render.call(this,context,x,y);
			Stat._show && Stat._sp && Stat._sp.render(context,x,y);
			context.gl.commit();
		}
	}

	/**@private */
	__proto._requestFullscreen=function(){
		var element=Browser.document.documentElement;
		if (element.requestFullscreen){
			element.requestFullscreen();
			}else if (element.mozRequestFullScreen){
			element.mozRequestFullScreen();
			}else if (element.webkitRequestFullscreen){
			element.webkitRequestFullscreen();
			}else if (element.msRequestFullscreen){
			element.msRequestFullscreen();
		}
	}

	/**@private */
	__proto._fullScreenChanged=function(){
		Laya.stage.event("fullscreenchange");
	}

	/**退出全屏模式*/
	__proto.exitFullscreen=function(){
		var document=Browser.document;
		if (document.exitFullscreen){
			document.exitFullscreen();
			}else if (document.mozCancelFullScreen){
			document.mozCancelFullScreen();
			}else if (document.webkitExitFullscreen){
			document.webkitExitFullscreen();
		}
	}

	/**当前视窗由缩放模式导致的 Y 轴缩放系数。*/
	__getset(0,__proto,'clientScaleY',function(){
		return this._transform ? this._transform.getScaleY():1;
	});

	/**@inheritDoc */
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		this.designWidth=value;
		Laya.superSet(Sprite,this,'width',value);
		Laya.systemTimer.callLater(this,this._changeCanvasSize);
	});

	/**
	*舞台是否获得焦点。
	*/
	__getset(0,__proto,'isFocused',function(){
		return this._isFocused;
	});

	/**
	*<p>水平对齐方式。默认值为"left"。</p>
	*<p><ul>取值范围：
	*<li>"left" ：居左对齐；</li>
	*<li>"center" ：居中对齐；</li>
	*<li>"right" ：居右对齐；</li>
	*</ul></p>
	*/
	__getset(0,__proto,'alignH',function(){
		return this._alignH;
		},function(value){
		this._alignH=value;
		Laya.systemTimer.callLater(this,this._changeCanvasSize);
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		this.designHeight=value;
		Laya.superSet(Sprite,this,'height',value);
		Laya.systemTimer.callLater(this,this._changeCanvasSize);
	});

	/**@inheritDoc */
	__getset(0,__proto,'transform',function(){
		if (this._tfChanged)this._adjustTransform();
		return this._transform=this._transform|| this._createTransform();
	},_super.prototype._$set_transform);

	/**
	*舞台是否处于可见状态(是否进入后台)。
	*/
	__getset(0,__proto,'isVisibility',function(){
		return this._isVisibility;
	});

	/**
	*<p>缩放模式。默认值为 "noscale"。</p>
	*<p><ul>取值范围：
	*<li>"noscale" ：不缩放；</li>
	*<li>"exactfit" ：全屏不等比缩放；</li>
	*<li>"showall" ：最小比例缩放；</li>
	*<li>"noborder" ：最大比例缩放；</li>
	*<li>"full" ：不缩放，stage的宽高等于屏幕宽高；</li>
	*<li>"fixedwidth" ：宽度不变，高度根据屏幕比缩放；</li>
	*<li>"fixedheight" ：高度不变，宽度根据屏幕比缩放；</li>
	*<li>"fixedauto" ：根据宽高比，自动选择使用fixedwidth或fixedheight；</li>
	*</ul></p>
	*/
	__getset(0,__proto,'scaleMode',function(){
		return this._scaleMode;
		},function(value){
		this._scaleMode=value;
		Laya.systemTimer.callLater(this,this._changeCanvasSize);
	});

	/**
	*<p>垂直对齐方式。默认值为"top"。</p>
	*<p><ul>取值范围：
	*<li>"top" ：居顶部对齐；</li>
	*<li>"middle" ：居中对齐；</li>
	*<li>"bottom" ：居底部对齐；</li>
	*</ul></p>
	*/
	__getset(0,__proto,'alignV',function(){
		return this._alignV;
		},function(value){
		this._alignV=value;
		Laya.systemTimer.callLater(this,this._changeCanvasSize);
	});

	/**舞台的背景颜色，默认为黑色，null为透明。*/
	__getset(0,__proto,'bgColor',function(){
		return this._bgColor;
		},function(value){
		this._bgColor=value;
		if (Render.isWebGL){
			if (value)
				this._wgColor=ColorUtils.create(value).arrColor;
			else
			this._wgColor=null;
		}
		if (Browser.onLimixiu){
			this._wgColor=ColorUtils.create(value).arrColor;
			}else if (value){
			Render.canvas.style.background=value;
			}else {
			Render.canvas.style.background="none";
		}
		if (Render.isConchApp){
			this._renderType |=0x80;
			this._setBgStyleColor(0,0,this.width,this.height,value);
			this._setRenderType(this._renderType);
		}
	});

	/**鼠标在 Stage 上的 X 轴坐标。*/
	__getset(0,__proto,'mouseX',function(){
		return Math.round(MouseManager.instance.mouseX / this.clientScaleX);
	});

	/**鼠标在 Stage 上的 Y 轴坐标。*/
	__getset(0,__proto,'mouseY',function(){
		return Math.round(MouseManager.instance.mouseY / this.clientScaleY);
	});

	/**当前视窗由缩放模式导致的 X 轴缩放系数。*/
	__getset(0,__proto,'clientScaleX',function(){
		return this._transform ? this._transform.getScaleX():1;
	});

	/**
	*<p>场景布局类型。</p>
	*<p><ul>取值范围：
	*<li>"none" ：不更改屏幕</li>
	*<li>"horizontal" ：自动横屏</li>
	*<li>"vertical" ：自动竖屏</li>
	*</ul></p>
	*/
	__getset(0,__proto,'screenMode',function(){
		return this._screenMode;
		},function(value){
		this._screenMode=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'visible',_super.prototype._$get_visible,function(value){
		if (this.visible!==value){
			Laya.superSet(Sprite,this,'visible',value);
			var style=Render._mainCanvas.source.style;
			style.visibility=value ? "visible" :"hidden";
		}
	});

	/**
	*<p>是否开启全屏，用户点击后进入全屏。</p>
	*<p>兼容性提示：部分浏览器不允许点击进入全屏，比如Iphone等。</p>
	*/
	__getset(0,__proto,'fullScreenEnabled',null,function(value){
		var document=Browser.document;
		var canvas=Render.canvas;
		if (value){
			canvas.addEventListener('mousedown',this._requestFullscreen);
			canvas.addEventListener('touchstart',this._requestFullscreen);
			document.addEventListener("fullscreenchange",this._fullScreenChanged);
			document.addEventListener("mozfullscreenchange",this._fullScreenChanged);
			document.addEventListener("webkitfullscreenchange",this._fullScreenChanged);
			document.addEventListener("msfullscreenchange",this._fullScreenChanged);
			}else {
			canvas.removeEventListener('mousedown',this._requestFullscreen);
			canvas.removeEventListener('touchstart',this._requestFullscreen);
			document.removeEventListener("fullscreenchange",this._fullScreenChanged);
			document.removeEventListener("mozfullscreenchange",this._fullScreenChanged);
			document.removeEventListener("webkitfullscreenchange",this._fullScreenChanged);
			document.removeEventListener("msfullscreenchange",this._fullScreenChanged);
		}
	});

	__getset(0,__proto,'frameRate',function(){
		if (!Render.isConchApp){
			return this._frameRate;
		}
		else{
			return this._frameRateNative;
		}
		},function(value){
		if (!Render.isConchApp){
			this._frameRate=value;
		}
		else{
			switch(value){
				case "fast":
					window.conch.config.setLimitFPS(60);
					break ;
				case "mouse":
					window.conch.config.setMouseFrame(2000);
					break ;
				case "slow":
					window.conch.config.setSlowFrame(true);
					break ;
				case "sleep":
					window.conch.config.setLimitFPS(1);
					break ;
				}
			this._frameRateNative=value;
		}
	});

	Stage.SCALE_NOSCALE="noscale";
	Stage.SCALE_EXACTFIT="exactfit";
	Stage.SCALE_SHOWALL="showall";
	Stage.SCALE_NOBORDER="noborder";
	Stage.SCALE_FULL="full";
	Stage.SCALE_FIXED_WIDTH="fixedwidth";
	Stage.SCALE_FIXED_HEIGHT="fixedheight";
	Stage.SCALE_FIXED_AUTO="fixedauto";
	Stage.ALIGN_LEFT="left";
	Stage.ALIGN_RIGHT="right";
	Stage.ALIGN_CENTER="center";
	Stage.ALIGN_TOP="top";
	Stage.ALIGN_MIDDLE="middle";
	Stage.ALIGN_BOTTOM="bottom";
	Stage.SCREEN_NONE="none";
	Stage.SCREEN_HORIZONTAL="horizontal";
	Stage.SCREEN_VERTICAL="vertical";
	Stage.FRAME_FAST="fast";
	Stage.FRAME_SLOW="slow";
	Stage.FRAME_MOUSE="mouse";
	Stage.FRAME_SLEEP="sleep";
	return Stage;
})(Sprite)


//class laya.ui.UIComponent extends laya.display.Sprite
var UIComponent=(function(_super){
	function UIComponent(){
		/**@private 控件的数据源。 */
		this._dataSource=null;
		/**@private 鼠标悬停提示 */
		this._toolTip=null;
		/**@private 标签 */
		this._tag=null;
		/**@private 禁用 */
		this._disabled=false;
		/**@private 变灰*/
		this._gray=false;
		UIComponent.__super.call(this);
		this._anchorX=NaN;
		this._anchorY=NaN;
		this._widget=Widget.EMPTY;
		this.preinitialize();
		this.createChildren();
		this.initialize();
	}

	__class(UIComponent,'laya.ui.UIComponent',_super);
	var __proto=UIComponent.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._dataSource=null;
		this._tag=null;
		this._toolTip=null;
	}

	/**
	*<p>预初始化。</p>
	*@internal 子类可在此函数内设置、修改属性默认值
	*/
	__proto.preinitialize=function(){}
	/**
	*<p>创建并添加控件子节点。</p>
	*@internal 子类可在此函数内创建并添加子节点。
	*/
	__proto.createChildren=function(){}
	/**
	*<p>控件初始化。</p>
	*@internal 在此子对象已被创建，可以对子对象进行修改。
	*/
	__proto.initialize=function(){}
	/**
	*<p>显示对象的实际显示区域宽度（以像素为单位）。</p>
	*/
	__proto.measureWidth=function(){
		var max=0;
		this.commitMeasure();
		for (var i=this.numChildren-1;i >-1;i--){
			var comp=this.getChildAt(i);
			if (comp._visible){
				max=Math.max(comp._x+comp.width *comp.scaleX,max);
			}
		}
		return max;
	}

	/**
	*<p>立即执行影响宽高度量的延迟调用函数。</p>
	*@internal <p>使用 <code>runCallLater</code> 函数，立即执行影响宽高度量的延迟运行函数(使用 <code>callLater</code> 设置延迟执行函数)。</p>
	*@see #callLater()
	*@see #runCallLater()
	*/
	__proto.commitMeasure=function(){}
	/**
	*<p>显示对象的实际显示区域高度（以像素为单位）。</p>
	*/
	__proto.measureHeight=function(){
		var max=0;
		this.commitMeasure();
		for (var i=this.numChildren-1;i >-1;i--){
			var comp=this.getChildAt(i);
			if (comp._visible){
				max=Math.max(comp._y+comp.height *comp.scaleY,max);
			}
		}
		return max;
	}

	__proto._sizeChanged=function(){
		if (!isNaN(this._anchorX))this.pivotX=this.anchorX *this.width;
		if (!isNaN(this._anchorY))this.pivotY=this.anchorY *this.height;
		this.event("resize");
		if (this._widget!==Widget.EMPTY)this._widget.resetLayout();
	}

	/**
	*对象的 <code>Event.MOUSE_OVER</code> 事件侦听处理函数。
	*/
	__proto.onMouseOver=function(e){
		Laya.stage.event("showtip",this._toolTip);
	}

	/**
	*对象的 <code>Event.MOUSE_OUT</code> 事件侦听处理函数。
	*/
	__proto.onMouseOut=function(e){
		Laya.stage.event("hidetip",this._toolTip);
	}

	/**
	*@private
	*<p>获取对象的布局样式。请不要直接修改此对象</p>
	*/
	__proto._getWidget=function(){
		this._widget===Widget.EMPTY && (this._widget=this.addComponent(Widget));
		return this._widget;
	}

	/**@private */
	__proto.onCompResize=function(){
		this._sizeChanged();
	}

	__proto._childChanged=function(child){
		this.callLater(this._sizeChanged);
		_super.prototype._childChanged.call(this,child);
	}

	/**
	*<p>在父容器中，此对象的垂直方向中轴线与父容器的垂直方向中心线的距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'centerY',function(){
		return this._widget.centerY;
		},function(value){
		if (value !=this._widget.centerY){
			this._getWidget().centerY=value;
		}
	});

	/**@inheritDoc */
	/**
	*<p>表示显示对象的宽度，以像素为单位。</p>
	*<p><b>注：</b>当值为0时，宽度为自适应大小。</p>
	*/
	__getset(0,__proto,'width',function(){
		if (this._width)return this._width;
		return this.measureWidth();
		},function(value){
		if (Laya.superGet(Sprite,this,'width')==value)return;
		Laya.superSet(Sprite,this,'width',value);
		this.callLater(this._sizeChanged);
	});

	/**
	*<p>从组件底边到其内容区域底边之间的垂直距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'bottom',function(){
		return this._widget.bottom;
		},function(value){
		if (value !=this._widget.bottom){
			this._getWidget().bottom=value;
		}
	});

	/**@inheritDoc */
	/**
	*<p>表示显示对象的高度，以像素为单位。</p>
	*<p><b>注：</b>当值为0时，高度为自适应大小。</p>
	*/
	__getset(0,__proto,'height',function(){
		if (this._height)return this._height;
		return this.measureHeight();
		},function(value){
		if (Laya.superGet(Sprite,this,'height')==value)return;
		Laya.superSet(Sprite,this,'height',value);
		this.callLater(this._sizeChanged);
	});

	/**
	*<p>从组件左边到其内容区域左边之间的水平距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'left',function(){
		return this._widget.left;
		},function(value){
		if (value !=this._widget.left){
			this._getWidget().left=value;
		}
	});

	/**
	*<p>数据赋值，通过对UI赋值来控制UI显示逻辑。</p>
	*<p>简单赋值会更改组件的默认属性，使用大括号可以指定组件的任意属性进行赋值。</p>
	*@example
	//默认属性赋值
	dataSource={label1:"改变了label",checkbox1:true};//(更改了label1的text属性值，更改checkbox1的selected属性)。
	//任意属性赋值
	dataSource={label2:{text:"改变了label",size:14},checkbox2:{selected:true,x:10}};
	*/
	__getset(0,__proto,'dataSource',function(){
		return this._dataSource;
		},function(value){
		this._dataSource=value;
		for (var prop in this._dataSource){
			if (this.hasOwnProperty(prop)&& !((typeof (this[prop])=='function'))){
				this[prop]=this._dataSource[prop];
			}
		}
	});

	/**
	*<p>在父容器中，此对象的水平方向中轴线与父容器的水平方向中心线的距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'centerX',function(){
		return this._widget.centerX;
		},function(value){
		if (value !=this._widget.centerX){
			this._getWidget().centerX=value;
		}
	});

	/**
	*<p>从组件顶边到其内容区域顶边之间的垂直距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'top',function(){
		return this._widget.top;
		},function(value){
		if (value !=this._widget.top){
			this._getWidget().top=value;
		}
	});

	/**
	*<p>从组件右边到其内容区域右边之间的水平距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'right',function(){
		return this._widget.right;
		},function(value){
		if (value !=this._widget.right){
			this._getWidget().right=value;
		}
	});

	/**
	*<p>对象的标签。</p>
	*@internal 冗余字段，可以用来储存数据。
	*/
	__getset(0,__proto,'tag',function(){
		return this._tag;
		},function(value){
		this._tag=value;
	});

	/**
	*<p>鼠标悬停提示。</p>
	*<p>可以赋值为文本 <code>String</code> 或函数 <code>Handler</code> ，用来实现自定义样式的鼠标提示和参数携带等。</p>
	*@example
	*private var _testTips:TestTipsUI=new TestTipsUI();
	*private function testTips():void {
		//简单鼠标提示
		*btn2.toolTip="这里是鼠标提示&lt;b&gt;粗体&lt;/b&gt;&lt;br&gt;换行";
		//自定义的鼠标提示
		*btn1.toolTip=showTips1;
		//带参数的自定义鼠标提示
		*clip.toolTip=new Handler(this,showTips2,["clip"]);
		*}
	*private function showTips1():void {
		*_testTips.label.text="这里是按钮["+btn1.label+"]";
		*tip.addChild(_testTips);
		*}
	*private function showTips2(name:String):void {
		*_testTips.label.text="这里是"+name;
		*tip.addChild(_testTips);
		*}
	*/
	__getset(0,__proto,'toolTip',function(){
		return this._toolTip;
		},function(value){
		if (this._toolTip !=value){
			this._toolTip=value;
			if (value !=null){
				this.on("mouseover",this,this.onMouseOver);
				this.on("mouseout",this,this.onMouseOut);
				}else {
				this.off("mouseover",this,this.onMouseOver);
				this.off("mouseout",this,this.onMouseOut);
			}
		}
	});

	/**是否变灰。*/
	__getset(0,__proto,'gray',function(){
		return this._gray;
		},function(value){
		if (value!==this._gray){
			this._gray=value;
			UIUtils.gray(this,value);
		}
	});

	/**是否禁用页面，设置为true后，会变灰并且禁用鼠标。*/
	__getset(0,__proto,'disabled',function(){
		return this._disabled;
		},function(value){
		if (value!==this._disabled){
			this.gray=this._disabled=value;
			this.mouseEnabled=!value;
		}
	});

	/**@inheritDoc */
	__getset(0,__proto,'scaleX',_super.prototype._$get_scaleX,function(value){
		if (Laya.superGet(Sprite,this,'scaleX')==value)return;
		Laya.superSet(Sprite,this,'scaleX',value);
		this.event("resize");
	});

	/**@inheritDoc */
	__getset(0,__proto,'scaleY',_super.prototype._$get_scaleY,function(value){
		if (Laya.superGet(Sprite,this,'scaleY')==value)return;
		Laya.superSet(Sprite,this,'scaleY',value);
		this.event("resize");
	});

	/**X锚点，值为0-1，设置anchorX值最终通过pivotX值来改变节点轴心点。*/
	__getset(0,__proto,'anchorX',function(){
		return this._anchorX;
		},function(value){
		if (this._anchorX !=value){
			this._anchorX=value;
			this.callLater(this._sizeChanged);
		}
	});

	/**Y锚点，值为0-1，设置anchorY值最终通过pivotY值来改变节点轴心点。*/
	__getset(0,__proto,'anchorY',function(){
		return this._anchorY;
		},function(value){
		if (this._anchorY !=value){
			this._anchorY=value
			this.callLater(this._sizeChanged);
		}
	});

	return UIComponent;
})(Sprite)


//class laya.ui.DialogManager extends laya.display.Sprite
var DialogManager=(function(_super){
	function DialogManager(){
		/**锁屏层*/
		this.lockLayer=null;
		/**@private 全局默认弹出对话框效果，可以设置一个效果代替默认的弹出效果，如果不想有任何效果，可以赋值为null*/
		this.popupEffect=function(dialog){
			dialog.scale(1,1);
			Tween.from(dialog,{x:Laya.stage.width / 2,y:Laya.stage.height / 2,scaleX:0,scaleY:0},300,Ease.backOut,Handler.create(this,this.doOpen,[dialog]));
		}
		/**@private 全局默认关闭对话框效果，可以设置一个效果代替默认的关闭效果，如果不想有任何效果，可以赋值为null*/
		this.closeEffect=function(dialog){
			Tween.to(dialog,{x:Laya.stage.width / 2,y:Laya.stage.height / 2,scaleX:0,scaleY:0},300,Ease.strongOut,Handler.create(this,this.doClose,[dialog]));
		}
		DialogManager.__super.call(this);
		this.maskLayer=new Sprite();
		this.popupEffectHandler=new Handler(this,this.popupEffect);
		this.closeEffectHandler=new Handler(this,this.closeEffect);
		this.mouseEnabled=this.maskLayer.mouseEnabled=true;
		this.zOrder=1000;
		Laya.stage.addChild(this);
		Laya.stage.on("resize",this,this._onResize);
		if (UIConfig.closeDialogOnSide)this.maskLayer.on("click",this,this._closeOnSide);
		this._onResize(null);
	}

	__class(DialogManager,'laya.ui.DialogManager',_super);
	var __proto=DialogManager.prototype;
	__proto._closeOnSide=function(){
		var dialog=this.getChildAt(this.numChildren-1);
		if ((dialog instanceof laya.ui.Dialog ))dialog.close();
	}

	/**设置锁定界面，如果为空则什么都不显示*/
	__proto.setLockView=function(value){
		if (!this.lockLayer){
			this.lockLayer=new Box();
			this.lockLayer.mouseEnabled=true;
			this.lockLayer.size(Laya.stage.width,Laya.stage.height);
		}
		this.lockLayer.removeChildren();
		if (value){
			value.centerX=value.centerY=0;
			this.lockLayer.addChild(value);
		}
	}

	/**@private */
	__proto._onResize=function(e){
		var width=this.maskLayer.width=Laya.stage.width;
		var height=this.maskLayer.height=Laya.stage.height;
		if (this.lockLayer)this.lockLayer.size(width,height);
		this.maskLayer.graphics.clear(true);
		this.maskLayer.graphics.drawRect(0,0,width,height,UIConfig.popupBgColor);
		this.maskLayer.alpha=UIConfig.popupBgAlpha;
		for (var i=this.numChildren-1;i >-1;i--){
			var item=this.getChildAt(i);
			if (item.isPopupCenter)this._centerDialog(item);
		}
	}

	__proto._centerDialog=function(dialog){
		dialog.x=Math.round(((Laya.stage.width-dialog.width)>> 1)+dialog.pivotX);
		dialog.y=Math.round(((Laya.stage.height-dialog.height)>> 1)+dialog.pivotY);
	}

	/**
	*显示对话框
	*@param dialog 需要显示的对象框 <code>Dialog</code> 实例。
	*@param closeOther 是否关闭其它对话框，若值为ture，则关闭其它的对话框。
	*@param showEffect 是否显示弹出效果
	*/
	__proto.open=function(dialog,closeOther,showEffect){
		(closeOther===void 0)&& (closeOther=false);
		(showEffect===void 0)&& (showEffect=false);
		if (closeOther)this._closeAll();
		if (dialog.isPopupCenter)this._centerDialog(dialog);
		this.addChild(dialog);
		if (dialog.isModal || this._getBit(0x20))Laya.timer.callLater(this,this._checkMask);
		if (showEffect && dialog.popupEffect !=null)dialog.popupEffect.runWith(dialog);
		else this.doOpen(dialog);
		this.event("open");
	}

	/**
	*执行打开对话框。
	*@param dialog 需要关闭的对象框 <code>Dialog</code> 实例。
	*/
	__proto.doOpen=function(dialog){
		dialog.onOpened();
	}

	/**
	*锁定所有层，显示加载条信息，防止双击
	*/
	__proto.lock=function(value){
		if (this.lockLayer){
			if (value)this.addChild(this.lockLayer);
			else this.lockLayer.removeSelf();
		}
	}

	/**
	*关闭对话框。
	*@param dialog 需要关闭的对象框 <code>Dialog</code> 实例。
	*/
	__proto.close=function(dialog){
		if (dialog.isShowEffect && dialog.closeEffect !=null)dialog.closeEffect.runWith([dialog]);
		else this.doClose(dialog);
		this.event("close");
	}

	/**
	*执行关闭对话框。
	*@param dialog 需要关闭的对象框 <code>Dialog</code> 实例。
	*/
	__proto.doClose=function(dialog){
		dialog.removeSelf();
		dialog.isModal && this._checkMask();
		dialog.closeHandler && dialog.closeHandler.runWith(dialog.closeType);
		dialog.onClosed(dialog.closeType);
	}

	/**
	*关闭所有的对话框。
	*/
	__proto.closeAll=function(){
		this._closeAll();
		this.event("close");
	}

	/**@private */
	__proto._closeAll=function(){
		for (var i=this.numChildren-1;i >-1;i--){
			var item=this.getChildAt(i);
			if (item && item.close !=null){
				this.doClose(item);
			}
		}
	}

	/**
	*根据组获取所有对话框
	*@param group 组名称
	*@return 对话框数组
	*/
	__proto.getDialogsByGroup=function(group){
		var arr=[];
		for (var i=this.numChildren-1;i >-1;i--){
			var item=this.getChildAt(i);
			if (item && item.group===group){
				arr.push(item);
			}
		}
		return arr;
	}

	/**
	*根据组关闭所有弹出框
	*@param group 需要关闭的组名称
	*@return 需要关闭的对话框数组
	*/
	__proto.closeByGroup=function(group){
		var arr=[];
		for (var i=this.numChildren-1;i >-1;i--){
			var item=this.getChildAt(i);
			if (item && item.group===group){
				item.close();
				arr.push(item);
			}
		}
		return arr;
	}

	/**@private 发生层次改变后，重新检查遮罩层是否正确*/
	__proto._checkMask=function(){
		this.maskLayer.removeSelf();
		for (var i=this.numChildren-1;i >-1;i--){
			var dialog=this.getChildAt(i);
			if (dialog && dialog.isModal){
				this.addChildAt(this.maskLayer,i);
				return;
			}
		}
	}

	return DialogManager;
})(Sprite)


//class laya.resource.HTMLCanvas extends laya.resource.Bitmap
var HTMLCanvas=(function(_super){
	function HTMLCanvas(createCanvas){
		//this._ctx=null;
		//this._source=null;
		//this._texture=null;
		HTMLCanvas.__super.call(this);
		(createCanvas===void 0)&& (createCanvas=false);
		if(createCanvas || !Render.isWebGL)
			this._source=Browser.createElement("canvas");
		else {
			this._source=this;
		}
		this.lock=true;
	}

	__class(HTMLCanvas,'laya.resource.HTMLCanvas',_super);
	var __proto=HTMLCanvas.prototype;
	__proto._getSource=function(){
		return this._source;
	}

	/**
	*清空画布内容。
	*/
	__proto.clear=function(){
		this._ctx && this._ctx.clear();
		if (this._texture){
			this._texture.destroy();
			this._texture=null;
		}
	}

	/**
	*销毁。
	*/
	__proto.destroy=function(){
		this._ctx && this._ctx.destroy();
		this._ctx=null;
	}

	/**
	*释放。
	*/
	__proto.release=function(){}
	/**
	*@private
	*设置 Canvas 渲染上下文。是webgl用来替换_ctx用的
	*@param context Canvas 渲染上下文。
	*/
	__proto._setContext=function(context){
		this._ctx=context;
	}

	/**
	*获取 Canvas 渲染上下文。
	*@param contextID 上下文ID.
	*@param other
	*@return Canvas 渲染上下文 Context 对象。
	*/
	__proto.getContext=function(contextID,other){
		return this.context;
	}

	//TODO:coverage
	__proto.getMemSize=function(){
		return 0;
	}

	/**
	*设置宽高。
	*@param w 宽度。
	*@param h 高度。
	*/
	__proto.size=function(w,h){
		if (this._width !=w || this._height !=h || (this._source && (this._source.width !=w || this._source.height !=h))){
			this._width=w;
			this._height=h;
			this._setGPUMemory(w *h *4);
			this._ctx && this._ctx.size && this._ctx.size(w,h);
			this._source && (this._source.height=h,this._source.width=w);
			if (this._texture){
				this._texture.destroy();
				this._texture=null;
			}
		}
	}

	/**
	*获取texture实例
	*/
	__proto.getTexture=function(){
		if (!this._texture){
			this._texture=new Texture(this,Texture.DEF_UV);
		}
		return this._texture;
	}

	/**
	*把图片转换为base64信息
	*@param type "image/png"
	*@param encoderOptions 质量参数，取值范围为0-1
	*@param callBack 完成回调，返回base64数据
	*/
	__proto.toBase64=function(type,encoderOptions,callBack){
		if (this._source){
			if (Render.isConchApp && this._source.toBase64){
				this._source.toBase64(type,encoderOptions,callBack);
			}
			else {
				var base64Data=this._source.toDataURL(type,encoderOptions);
				callBack(base64Data);
			}
		}
	}

	/**
	*@inheritDoc
	*/
	__getset(0,__proto,'source',function(){
		return this._source;
	});

	/**
	*Canvas 渲染上下文。
	*/
	__getset(0,__proto,'context',function(){
		if (this._ctx)return this._ctx;
		if (Render.isWebGL && this._source==this){
			this._ctx=new laya.webgl.canvas.WebGLContext2D();;
			}else {
			this._ctx=this._source.getContext(Render.isConchApp?'layagl':'2d');
		}
		this._ctx._canvas=this;
		return this._ctx;
	});

	return HTMLCanvas;
})(Bitmap)


//class laya.resource.HTMLImage extends laya.resource.Bitmap
var HTMLImage=(function(_super){
	function HTMLImage(){
		/**@private */
		//this._source=null;
		HTMLImage.__super.call(this);
	}

	__class(HTMLImage,'laya.resource.HTMLImage',_super);
	var __proto=HTMLImage.prototype;
	/**
	*通过图片源填充纹理,可为HTMLImageElement、HTMLCanvasElement、HTMLVideoElement、ImageBitmap、ImageData。
	*/
	__proto.loadImageSource=function(source){
		var width=source.width;
		var height=source.height;
		if (width <=0 || height <=0)
			throw new Error("HTMLImage:width or height must large than 0.");
		this._width=width;
		this._height=height;
		this._source=source;
		this._setGPUMemory(width *height *4);
		this._activeResource();
	}

	//TODO:coverage
	__proto._disposeResource=function(){
		(this._source)&& (this._source=null,this._setGPUMemory(0));
	}

	//TODO:coverage
	__proto._getSource=function(){
		return this._source;
	}

	HTMLImage.create=function(width,height){
		return new HTMLImage();
	}

	return HTMLImage;
})(Bitmap)


//class laya.display.Input extends laya.display.Text
var Input=(function(_super){
	function Input(){
		/**@private */
		this._focus=false;
		/**@private */
		this._multiline=false;
		/**@private */
		this._editable=true;
		/**@private */
		this._restrictPattern=null;
		this._type="text";
		/**输入提示符。*/
		this._prompt='';
		/**输入提示符颜色。*/
		this._promptColor="#A9A9A9";
		this._originColor="#000000";
		this._content='';
		Input.__super.call(this);
		this._maxChars=1E5;
		this._width=100;
		this._height=20;
		this.multiline=false;
		this.overflow="scroll";
		this.on("mousedown",this,this._onMouseDown);
		this.on("undisplay",this,this._onUnDisplay);
	}

	__class(Input,'laya.display.Input',_super);
	var __proto=Input.prototype;
	/**
	*设置光标位置和选取字符。
	*@param startIndex 光标起始位置。
	*@param endIndex 光标结束位置。
	*/
	__proto.setSelection=function(startIndex,endIndex){
		this.focus=true;
		laya.display.Input.inputElement.selectionStart=startIndex;
		laya.display.Input.inputElement.selectionEnd=endIndex;
	}

	__proto._onUnDisplay=function(e){
		this.focus=false;
	}

	__proto._onMouseDown=function(e){
		this.focus=true;
	}

	/**
	*在输入期间，如果 Input 实例的位置改变，调用_syncInputTransform同步输入框的位置。
	*/
	__proto._syncInputTransform=function(){
		var inputElement=this.nativeInput;
		var transform=Utils.getTransformRelativeToWindow(this,this.padding[3],this.padding[0]);
		var inputWid=this._width-this.padding[1]-this.padding[3];
		var inputHei=this._height-this.padding[0]-this.padding[2];
		if (Render.isConchApp){
			inputElement.setScale(transform.scaleX,transform.scaleY);
			inputElement.setSize(inputWid,inputHei);
			inputElement.setPos(transform.x,transform.y);
			}else {
			Input.inputContainer.style.transform=Input.inputContainer.style.webkitTransform="scale("+transform.scaleX+","+transform.scaleY+") rotate("+(Laya.stage.canvasDegree)+"deg)";
			inputElement.style.width=inputWid+'px';
			inputElement.style.height=inputHei+'px';
			Input.inputContainer.style.left=transform.x+'px';
			Input.inputContainer.style.top=transform.y+'px';
		}
	}

	/**选中当前实例的所有文本。*/
	__proto.select=function(){
		this.nativeInput.select();
	}

	__proto._setInputMethod=function(){
		Input.input.parentElement && (Input.inputContainer.removeChild(Input.input));
		Input.area.parentElement && (Input.inputContainer.removeChild(Input.area));
		Input.inputElement=(this._multiline ? Input.area :Input.input);
		Input.inputContainer.appendChild(Input.inputElement);
		if (Text.RightToLeft){
			Input.inputElement.style.direction="rtl";
		}
	}

	__proto._focusIn=function(){
		laya.display.Input.isInputting=true;
		var input=this.nativeInput;
		this._focus=true;
		var cssStyle=input.style;
		cssStyle.whiteSpace=(this.wordWrap ? "pre-wrap" :"nowrap");
		this._setPromptColor();
		input.readOnly=!this._editable;
		if (Render.isConchApp){
			input.setType(this._type);
			input.setForbidEdit(!this._editable);
		}
		input.maxLength=this._maxChars;
		var padding=this.padding;
		input.type=this._type;
		input.value=this._content;
		input.placeholder=this._prompt;
		Laya.stage.off("keydown",this,this._onKeyDown);
		Laya.stage.on("keydown",this,this._onKeyDown);
		Laya.stage.focus=this;
		this.event("focus");
		if (Browser.onPC)input.focus();
		if(!Browser.onMiniGame){
			var temp=this._text;
			this._text=null;
		}
		this.typeset();
		input.setColor(this._originColor);
		input.setFontSize(this.fontSize);
		input.setFontFace(Browser.onIPhone ? (Text.fontFamilyMap[this.font] || this.font):this.font);
		if (Render.isConchApp){
			input.setMultiAble && input.setMultiAble(this._multiline);
		}
		cssStyle.lineHeight=(this.leading+this.fontSize)+"px";
		cssStyle.fontStyle=(this.italic ? "italic" :"normal");
		cssStyle.fontWeight=(this.bold ? "bold" :"normal");
		cssStyle.textAlign=this.align;
		cssStyle.padding="0 0";
		this._syncInputTransform();
		if (!Render.isConchApp && Browser.onPC)
			Laya.systemTimer.frameLoop(1,this,this._syncInputTransform);
	}

	// 设置DOM输入框提示符颜色。
	__proto._setPromptColor=function(){
		Input.promptStyleDOM=Browser.getElementById("promptStyle");
		if (!Input.promptStyleDOM){
			Input.promptStyleDOM=Browser.createElement("style");
			Input.promptStyleDOM.setAttribute("id","promptStyle");
			Browser.document.head.appendChild(Input.promptStyleDOM);
		}
		Input.promptStyleDOM.innerText="input::-webkit-input-placeholder, textarea::-webkit-input-placeholder {"+"color:"+this._promptColor+"}"+"input:-moz-placeholder, textarea:-moz-placeholder {"+"color:"+this._promptColor+"}"+"input::-moz-placeholder, textarea::-moz-placeholder {"+"color:"+this._promptColor+"}"+"input:-ms-input-placeholder, textarea:-ms-input-placeholder {"+"color:"+this._promptColor+"}";
	}

	/**@private */
	__proto._focusOut=function(){
		laya.display.Input.isInputting=false;
		this._focus=false;
		this._text=null;
		this._content=this.nativeInput.value;
		if (!this._content){
			Laya.superSet(Text,this,'text',this._prompt);
			Laya.superSet(Text,this,'color',this._promptColor);
			}else {
			Laya.superSet(Text,this,'text',this._content);
			Laya.superSet(Text,this,'color',this._originColor);
		}
		Laya.stage.off("keydown",this,this._onKeyDown);
		Laya.stage.focus=null;
		this.event("blur");
		this.event("change");
		if (Render.isConchApp)this.nativeInput.blur();
		Browser.onPC && Laya.systemTimer.clear(this,this._syncInputTransform);
	}

	/**@private */
	__proto._onKeyDown=function(e){
		if (e.keyCode===13){
			if (Browser.onMobile && !this._multiline)
				this.focus=false;
			this.event("enter");
		}
	}

	__proto.changeText=function(text){
		this._content=text;
		if (this._focus){
			this.nativeInput.value=text || '';
			this.event("change");
		}else
		_super.prototype.changeText.call(this,text);
	}

	/**@inheritDoc */
	__getset(0,__proto,'color',_super.prototype._$get_color,function(value){
		if (this._focus)
			this.nativeInput.setColor(value);
		Laya.superSet(Text,this,'color',this._content?value:this._promptColor);
		this._originColor=value;
	});

	/**表示是否是多行输入框。*/
	__getset(0,__proto,'multiline',function(){
		return this._multiline;
		},function(value){
		this._multiline=value;
		this.valign=value ? "top" :"middle";
	});

	/**
	*<p>字符数量限制，默认为10000。</p>
	*<p>设置字符数量限制时，小于等于0的值将会限制字符数量为10000。</p>
	*/
	__getset(0,__proto,'maxChars',function(){
		return this._maxChars;
		},function(value){
		if (value <=0)
			value=1E5;
		this._maxChars=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'text',function(){
		if (this._focus)
			return this.nativeInput.value;
		else
		return this._content || "";
		},function(value){
		Laya.superSet(Text,this,'color',this._originColor);
		value+='';
		if (this._focus){
			this.nativeInput.value=value || '';
			this.event("change");
			}else {
			if (!this._multiline)
				value=value.replace(/\r?\n/g,'');
			this._content=value;
			if (value)
				Laya.superSet(Text,this,'text',value);
			else {
				Laya.superSet(Text,this,'text',this._prompt);
				Laya.superSet(Text,this,'color',this.promptColor);
			}
		}
	});

	/**
	*获取对输入框的引用实例。
	*/
	__getset(0,__proto,'nativeInput',function(){
		return this._multiline ? Input.area :Input.input;
	});

	/**
	*设置输入提示符。
	*/
	__getset(0,__proto,'prompt',function(){
		return this._prompt;
		},function(value){
		if (!this._text && value)
			Laya.superSet(Text,this,'color',this._promptColor);
		this.promptColor=this._promptColor;
		if (this._text)
			Laya.superSet(Text,this,'text',(this._text==this._prompt)?value:this._text);
		else
		Laya.superSet(Text,this,'text',value);
		this._prompt=Text.langPacks && Text.langPacks[value] ? Text.langPacks[value] :value;
	});

	// 因此 调用focus接口是无法都在移动平台立刻弹出键盘的
	/**
	*表示焦点是否在此实例上。
	*/
	__getset(0,__proto,'focus',function(){
		return this._focus;
		},function(value){
		var input=this.nativeInput;
		if (this._focus!==value){
			if (value){
				if (input.target){
					input.target._focusOut();
					}else {
					this._setInputMethod();
				}
				input.target=this;
				this._focusIn();
				}else {
				input.target=null;
				this._focusOut();
				Browser.document.body.scrollTop=0;
				input.blur();
				if (Render.isConchApp)input.setPos(-10000,-10000);
				else if (Input.inputContainer.contains(input))Input.inputContainer.removeChild(input);
			}
		}
	});

	/**限制输入的字符。*/
	__getset(0,__proto,'restrict',function(){
		if (this._restrictPattern){
			return this._restrictPattern.source;
		}
		return "";
		},function(pattern){
		if (pattern){
			pattern="[^"+pattern+"]";
			if (pattern.indexOf("^^")>-1)
				pattern=pattern.replace("^^","");
			this._restrictPattern=new RegExp(pattern,"g");
		}else
		this._restrictPattern=null;
	});

	/**
	*是否可编辑。
	*/
	__getset(0,__proto,'editable',function(){
		return this._editable;
		},function(value){
		this._editable=value;
		if (Render.isConchApp){
			Input.input.setForbidEdit(!value);
		}
	});

	/**
	*设置输入提示符颜色。
	*/
	__getset(0,__proto,'promptColor',function(){
		return this._promptColor;
		},function(value){
		this._promptColor=value;
		if (!this._content)Laya.superSet(Text,this,'color',value);
	});

	/**
	*<p>输入框类型为Input静态常量之一。</p>
	*<ul>
	*<li>TYPE_TEXT</li>
	*<li>TYPE_PASSWORD</li>
	*<li>TYPE_EMAIL</li>
	*<li>TYPE_URL</li>
	*<li>TYPE_NUMBER</li>
	*<li>TYPE_RANGE</li>
	*<li>TYPE_DATE</li>
	*<li>TYPE_MONTH</li>
	*<li>TYPE_WEEK</li>
	*<li>TYPE_TIME</li>
	*<li>TYPE_DATE_TIME</li>
	*<li>TYPE_DATE_TIME_LOCAL</li>
	*</ul>
	*<p>平台兼容性参见http://www.w3school.com.cn/html5/html_5_form_input_types.asp。</p>
	*/
	__getset(0,__proto,'type',function(){
		return this._type;
		},function(value){
		if (value==="password")this._getTextStyle().asPassword=true;
		else this._getTextStyle().asPassword=false;
		this._type=value;
	});

	Input.__init__=function(){
		Input._createInputElement();
		if (Browser.onMobile)
			Render.canvas.addEventListener(Input.IOS_IFRAME ?(Browser.onMiniGame ? "touchend" :"click"):"touchend",Input._popupInputMethod);
	}

	Input._popupInputMethod=function(e){
		if (!laya.display.Input.isInputting)return;
		var input=laya.display.Input.inputElement;
		input.focus();
	}

	Input._createInputElement=function(){
		Input._initInput(Input.area=Browser.createElement("textarea"));
		Input._initInput(Input.input=Browser.createElement("input"));
		Input.inputContainer=Browser.createElement("div");
		Input.inputContainer.style.position="absolute";
		Input.inputContainer.style.zIndex=1E5;
		Browser.container.appendChild(Input.inputContainer);
		Input.inputContainer.setPos=function (x,y){
			Input.inputContainer.style.left=x+'px';
			Input.inputContainer.style.top=y+'px';
		};
	}

	Input._initInput=function(input){
		var style=input.style;
		style.cssText="position:absolute;overflow:hidden;resize:none;transform-origin:0 0;-webkit-transform-origin:0 0;-moz-transform-origin:0 0;-o-transform-origin:0 0;";
		style.resize='none';
		style.backgroundColor='transparent';
		style.border='none';
		style.outline='none';
		style.zIndex=1;
		input.addEventListener('input',Input._processInputting);
		input.addEventListener('mousemove',Input._stopEvent);
		input.addEventListener('mousedown',Input._stopEvent);
		input.addEventListener('touchmove',Input._stopEvent);
		input.setFontFace=function (fontFace){input.style.fontFamily=fontFace;};
		if(!Render.isConchApp){
			input.setColor=function (color){input.style.color=color;};
			input.setFontSize=function (fontSize){input.style.fontSize=fontSize+'px';};
		}
	}

	Input._processInputting=function(e){
		var input=laya.display.Input.inputElement.target;
		if (!input)return;
		var value=laya.display.Input.inputElement.value;
		if (input._restrictPattern){
			value=value.replace(/\u2006|\x27/g,"");
			if (input._restrictPattern.test(value)){
				value=value.replace(input._restrictPattern,"");
				laya.display.Input.inputElement.value=value;
			}
		}
		input._text=value;
		input.event("input");
	}

	Input._stopEvent=function(e){
		if (e.type=='touchmove')
			e.preventDefault();
		e.stopPropagation && e.stopPropagation();
	}

	Input.TYPE_TEXT="text";
	Input.TYPE_PASSWORD="password";
	Input.TYPE_EMAIL="email";
	Input.TYPE_URL="url";
	Input.TYPE_NUMBER="number";
	Input.TYPE_RANGE="range";
	Input.TYPE_DATE="date";
	Input.TYPE_MONTH="month";
	Input.TYPE_WEEK="week";
	Input.TYPE_TIME="time";
	Input.TYPE_DATE_TIME="datetime";
	Input.TYPE_DATE_TIME_LOCAL="datetime-local";
	Input.TYPE_SEARCH="search";
	Input.input=null;
	Input.area=null;
	Input.inputElement=null;
	Input.inputContainer=null;
	Input.confirmButton=null;
	Input.promptStyleDOM=null;
	Input.inputHeight=45;
	Input.isInputting=false;
	Input.stageMatrix=null;
	__static(Input,
	['IOS_IFRAME',function(){return this.IOS_IFRAME=(Browser.onIOS && Browser.window.top !=Browser.window.self);}
	]);
	return Input;
})(Text)


//class laya.display.Animation extends laya.display.AnimationBase
var Animation=(function(_super){
	function Animation(){
		/**@private */
		this._frames=null;
		/**@private */
		this._url=null;
		Animation.__super.call(this);
		this._setControlNode(this);
	}

	__class(Animation,'laya.display.Animation',_super);
	var __proto=Animation.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		this.stop();
		laya.display.Sprite.prototype.destroy.call(this,destroyChild);
		this._frames=null;
		this._labels=null;
	}

	/**
	*<p>开始播放动画。会在动画模版缓存池中查找key值为name的动画模版，存在则用此动画模版初始化当前序列帧， 如果不存在，则使用当前序列帧。</p>
	*<p>play(...)方法被设计为在创建实例后的任何时候都可以被调用，调用后就处于播放状态，当相应的资源加载完毕、调用动画帧填充方法(set frames)或者将实例显示在舞台上时，会判断是否处于播放状态，如果是，则开始播放。</p>
	*<p>配合wrapMode属性，可设置动画播放顺序类型。</p>
	*@param start （可选）指定动画播放开始的索引(int)或帧标签(String)。帧标签可以通过addLabel(...)和removeLabel(...)进行添加和删除。
	*@param loop （可选）是否循环播放。
	*@param name （可选）动画模板在动画模版缓存池中的key，也可认为是动画名称。如果name为空，则播放当前动画序列帧；如果不为空，则在动画模版缓存池中寻找key值为name的动画模版，如果存在则用此动画模版初始化当前序列帧并播放，如果不存在，则仍然播放当前动画序列帧；如果没有当前动画的帧数据，则不播放，但该实例仍然处于播放状态。
	*/
	__proto.play=function(start,loop,name){
		(start===void 0)&& (start=0);
		(loop===void 0)&& (loop=true);
		(name===void 0)&& (name="");
		if (name)this._setFramesFromCache(name,true);
		_super.prototype.play.call(this,start,loop,name);
	}

	/**@private */
	__proto._setFramesFromCache=function(name,showWarn){
		(showWarn===void 0)&& (showWarn=false);
		if (this._url)name=this._url+"#"+name;
		if (name && Animation.framesMap[name]){
			var tAniO=Animation.framesMap[name];
			if ((tAniO instanceof Array)){
				this._frames=Animation.framesMap[name];
				this._count=this._frames.length;
				}else {
				if (tAniO.nodeRoot){
					Animation.framesMap[name]=GraphicAnimation.parseAnimationByData(tAniO);
					tAniO=Animation.framesMap[name];
				}
				this._frames=tAniO.frames;
				this._count=this._frames.length;
				if (!this._frameRateChanged)this._interval=tAniO.interval;
				this._labels=this._copyLabels(tAniO.labels);
			}
			return true;
			}else {
			if (showWarn)console.log("ani not found:",name);
		}
		return false;
	}

	/**@private */
	__proto._copyLabels=function(labels){
		if (!labels)return null;
		var rst;
		rst={};
		var key;
		for (key in labels){
			rst[key]=Utils.copyArray([],labels[key]);
		}
		return rst;
	}

	/**@private */
	__proto._frameLoop=function(){
		if (this._visible && this._style.alpha > 0.01 && this._frames){
			_super.prototype._frameLoop.call(this);
		}
	}

	/**@private */
	__proto._displayToIndex=function(value){
		if (this._frames)this.graphics=this._frames[value];
	}

	/**
	*停止动画播放，并清理对象属性。之后可存入对象池，方便对象复用。
	*/
	__proto.clear=function(){
		_super.prototype.clear.call(this);
		this.stop();
		this.graphics=null;
		this._frames=null;
		this._labels=null;
		return this;
	}

	/**
	*<p>根据指定的动画模版初始化当前动画序列帧。选择动画模版的过程如下：1. 动画模版缓存池中key为cacheName的动画模版；2. 如果不存在，则加载指定的图片集合并创建动画模版。注意：只有指定不为空的cacheName，才能将创建好的动画模版以此为key缓存到动画模版缓存池，否则不进行缓存。</p>
	*<p>动画模版缓存池是以一定的内存开销来节省CPU开销，当相同的动画模版被多次使用时，相比于每次都创建新的动画模版，使用动画模版缓存池，只需创建一次，缓存之后多次复用，从而节省了动画模版创建的开销。</p>
	*<p>因为返回值为Animation对象本身，所以可以使用如下语法：loadImages(...).loadImages(...).play(...);。</p>
	*@param urls 图片路径集合。需要创建动画模版时，会以此为数据源。参数形如：[url1,url2,url3,...]。
	*@param cacheName （可选）动画模板在动画模版缓存池中的key。如果此参数不为空，表示使用动画模版缓存池。如果动画模版缓存池中存在key为cacheName的动画模版，则使用此模版。否则，创建新的动画模版，如果cacheName不为空，则以cacheName为key缓存到动画模版缓存池中，如果cacheName为空，不进行缓存。
	*@return 返回Animation对象本身。
	*/
	__proto.loadImages=function(urls,cacheName){
		(cacheName===void 0)&& (cacheName="");
		this._url="";
		if (!this._setFramesFromCache(cacheName)){
			this.frames=Animation.framesMap[cacheName] ? Animation.framesMap[cacheName] :Animation.createFrames(urls,cacheName);
		}
		return this;
	}

	/**
	*<p>根据指定的动画模版初始化当前动画序列帧。选择动画模版的过程如下：1. 动画模版缓存池中key为cacheName的动画模版；2. 如果不存在，则加载指定的图集并创建动画模版。</p>
	*<p>注意：只有指定不为空的cacheName，才能将创建好的动画模版以此为key缓存到动画模版缓存池，否则不进行缓存。</p>
	*<p>动画模版缓存池是以一定的内存开销来节省CPU开销，当相同的动画模版被多次使用时，相比于每次都创建新的动画模版，使用动画模版缓存池，只需创建一次，缓存之后多次复用，从而节省了动画模版创建的开销。</p>
	*<p>因为返回值为Animation对象本身，所以可以使用如下语法：loadAtlas(...).loadAtlas(...).play(...);。</p>
	*@param url 图集路径。需要创建动画模版时，会以此为数据源。
	*@param loaded （可选）使用指定图集初始化动画完毕的回调。
	*@param cacheName （可选）动画模板在动画模版缓存池中的key。如果此参数不为空，表示使用动画模版缓存池。如果动画模版缓存池中存在key为cacheName的动画模版，则使用此模版。否则，创建新的动画模版，如果cacheName不为空，则以cacheName为key缓存到动画模版缓存池中，如果cacheName为空，不进行缓存。
	*@return 返回动画本身。
	*/
	__proto.loadAtlas=function(url,loaded,cacheName){
		(cacheName===void 0)&& (cacheName="");
		this._url="";
		var _this=this;
		if (!_this._setFramesFromCache(cacheName)){
			function onLoaded (loadUrl){
				if (url===loadUrl){
					_this.frames=Animation.framesMap[cacheName] ? Animation.framesMap[cacheName] :Animation.createFrames(url,cacheName);
					if (loaded)loaded.run();
				}
			}
			if (Loader.getAtlas(url))onLoaded(url);
			else Laya.loader.load(url,Handler.create(null,onLoaded,[url]),null,"atlas");
		}
		return this;
	}

	/**
	*<p>加载并解析由LayaAir IDE制作的动画文件，此文件中可能包含多个动画。默认帧率为在IDE中设计的帧率，如果调用过set interval，则使用此帧间隔对应的帧率。加载后创建动画模版，并缓存到动画模版缓存池，key "url#动画名称" 对应相应动画名称的动画模板，key "url#" 对应动画模版集合的默认动画模版。</p>
	*<p>注意：如果调用本方法前，还没有预加载动画使用的图集，请将atlas参数指定为对应的图集路径，否则会导致动画创建失败。</p>
	*<p>动画模版缓存池是以一定的内存开销来节省CPU开销，当相同的动画模版被多次使用时，相比于每次都创建新的动画模版，使用动画模版缓存池，只需创建一次，缓存之后多次复用，从而节省了动画模版创建的开销。</p>
	*<p>因为返回值为Animation对象本身，所以可以使用如下语法：loadAnimation(...).loadAnimation(...).play(...);。</p>
	*@param url 动画文件路径。可由LayaAir IDE创建并发布。
	*@param loaded （可选）使用指定动画资源初始化动画完毕的回调。
	*@param atlas （可选）动画用到的图集地址（可选）。
	*@return 返回动画本身。
	*/
	__proto.loadAnimation=function(url,loaded,atlas){
		this._url=url;
		var _this=this;
		if (!this._actionName)this._actionName="";
		if (!_this._setFramesFromCache(this._actionName)){
			if (!atlas || Loader.getAtlas(atlas)){
				this._loadAnimationData(url,loaded,atlas);
				}else {
				Laya.loader.load(atlas,Handler.create(this,this._loadAnimationData,[url,loaded,atlas]),null,"atlas")
			}
			}else {
			_this._setFramesFromCache(this._actionName,true);
			this.index=0;
			if (loaded)loaded.run();
		}
		return this;
	}

	/**@private */
	__proto._loadAnimationData=function(url,loaded,atlas){
		var _$this=this;
		if (atlas && !Loader.getAtlas(atlas)){
			console.warn("atlas load fail:"+atlas);
			return;
		};
		var _this=this;
		function onLoaded (loadUrl){
			if (!Loader.getRes(loadUrl))return;
			if (url===loadUrl){
				var tAniO;
				if (!Animation.framesMap[url+"#"]){
					var aniData=GraphicAnimation.parseAnimationData(Loader.getRes(url));
					if (!aniData)return;
					var aniList=aniData.animationList;
					var i=0,len=aniList.length;
					var defaultO;
					for (i=0;i < len;i++){
						tAniO=aniList[i];
						Animation.framesMap[url+"#"+tAniO.name]=tAniO;
						if (!defaultO)defaultO=tAniO;
					}
					if (defaultO){
						Animation.framesMap[url+"#"]=defaultO;
						_this._setFramesFromCache(_$this._actionName,true);
						_$this.index=0;
					}
					_$this._resumePlay();
					}else {
					_this._setFramesFromCache(_$this._actionName,true);
					_$this.index=0;
					_$this._resumePlay();
				}
				if (loaded)loaded.run();
			}
		}
		if (Loader.getRes(url))onLoaded(url);
		else Laya.loader.load(url,Handler.create(null,onLoaded,[url]),null,"json");
		Loader.clearRes(url);
	}

	/**
	*当前动画的帧图像数组。本类中，每个帧图像是一个Graphics对象，而动画播放就是定时切换Graphics对象的过程。
	*/
	__getset(0,__proto,'frames',function(){
		return this._frames;
		},function(value){
		this._frames=value;
		if (value){
			this._count=value.length;
			if (this._actionName)this._setFramesFromCache(this._actionName,true);
			this.index=this._index;
		}
	});

	/**
	*是否自动播放，默认为false。如果设置为true，则动画被创建并添加到舞台后自动播放。
	*/
	__getset(0,__proto,'autoPlay',null,function(value){
		if (value)this.play();
		else this.stop();
	});

	/**
	*<p>动画数据源。</p>
	*<p>类型如下：<br/>
	*1. LayaAir IDE动画文件路径：使用此类型需要预加载所需的图集资源，否则会创建失败，如果不想预加载或者需要创建完毕的回调，请使用loadAnimation(...)方法；<br/>
	*2. 图集路径：使用此类型创建的动画模版不会被缓存到动画模版缓存池中，如果需要缓存或者创建完毕的回调，请使用loadAtlas(...)方法；<br/>
	*3. 图片路径集合：使用此类型创建的动画模版不会被缓存到动画模版缓存池中，如果需要缓存，请使用loadImages(...)方法。</p>
	*@param value 数据源。比如：图集："xx/a1.atlas"；图片集合："a1.png,a2.png,a3.png"；LayaAir IDE动画"xx/a1.ani"。
	*/
	__getset(0,__proto,'source',null,function(value){
		if (value.indexOf(".ani")>-1)this.loadAnimation(value);
		else if (value.indexOf(".json")>-1 || value.indexOf("als")>-1 || value.indexOf("atlas")>-1)this.loadAtlas(value);
		else this.loadImages(value.split(","));
	});

	/**
	*设置自动播放的动画名称，在LayaAir IDE中可以创建的多个动画组成的动画集合，选择其中一个动画名称进行播放。
	*/
	__getset(0,__proto,'autoAnimation',null,function(value){
		this.play(0,true,value);
	});

	Animation.createFrames=function(url,name){
		var arr;
		if ((typeof url=='string')){
			var atlas=Loader.getAtlas(url);
			if (atlas && atlas.length){
				arr=[];
				for (var i=0,n=atlas.length;i < n;i++){
					var g=new Graphics();
					g.drawImage(Loader.getRes(atlas[i]),0,0);
					arr.push(g);
				}
			}
			}else if ((url instanceof Array)){
			arr=[];
			for (i=0,n=url.length;i < n;i++){
				g=new Graphics();
				g.loadImage(url[i],0,0);
				arr.push(g);
			}
		}
		if (name)Animation.framesMap[name]=arr;
		return arr;
	}

	Animation.clearCache=function(key){
		var cache=Animation.framesMap;
		var val;
		var key2=key+"#";
		for (val in cache){
			if (val===key || val.indexOf(key2)===0){
				delete Animation.framesMap[val];
			}
		}
	}

	Animation.framesMap={};
	return Animation;
})(AnimationBase)


//class laya.display.FrameAnimation extends laya.display.AnimationBase
var FrameAnimation=(function(_super){
	function FrameAnimation(){
		/**@private id对象表*/
		this._targetDic=null;
		/**@private 动画数据*/
		this._animationData=null;
		/**@private */
		this._usedFrames=null;
		FrameAnimation.__super.call(this);
		if (FrameAnimation._sortIndexFun===null){
			FrameAnimation._sortIndexFun=MathUtil.sortByKey("index",false,true);
		}
	}

	__class(FrameAnimation,'laya.display.FrameAnimation',_super);
	var __proto=FrameAnimation.prototype;
	/**
	*@private
	*初始化动画数据
	*@param targetDic 节点ID索引
	*@param animationData 动画数据
	*/
	__proto._setUp=function(targetDic,animationData){
		this._targetDic=targetDic;
		this._animationData=animationData;
		this.interval=1000 / animationData.frameRate;
		if (animationData.parsed){
			this._count=animationData.count;
			this._labels=animationData.labels;
			this._usedFrames=animationData.animationNewFrames;
			}else {
			this._usedFrames=[];
			this._calculateDatas();
			animationData.parsed=true;
			animationData.labels=this._labels;
			animationData.count=this._count;
			animationData.animationNewFrames=this._usedFrames;
		}
	}

	/**@inheritDoc */
	__proto.clear=function(){
		_super.prototype.clear.call(this);
		this._targetDic=null;
		this._animationData=null;
		return this;
	}

	/**@inheritDoc */
	__proto._displayToIndex=function(value){
		if (!this._animationData)return;
		if (value < 0)value=0;
		if (value > this._count)value=this._count;
		var nodes=this._animationData.nodes,i=0,len=nodes.length;
		for (i=0;i < len;i++){
			this._displayNodeToFrame(nodes[i],value);
		}
	}

	/**
	*@private
	*将节点设置到某一帧的状态
	*@param node 节点ID
	*@param frame
	*@param targetDic 节点表
	*/
	__proto._displayNodeToFrame=function(node,frame,targetDic){
		if (!targetDic)targetDic=this._targetDic;
		var target=targetDic[node.target];
		if (!target){
			return;
		};
		var frames=node.frames,key,propFrames,value;
		var keys=node.keys,i=0,len=keys.length;
		for (i=0;i < len;i++){
			key=keys[i];
			propFrames=frames[key];
			if (propFrames.length > frame){
				value=propFrames[frame];
				}else {
				value=propFrames[propFrames.length-1];
			}
			target[key]=value;
		};
		var funkeys=node.funkeys;
		len=funkeys.length;
		var funFrames;
		if (len==0)return;
		for (i=0;i < len;i++){
			key=funkeys[i];
			funFrames=frames[key];
			if (funFrames[frame]!==undefined){
				target[key]&&target[key].apply(target,funFrames[frame]);
			}
		}
	}

	/**
	*@private
	*计算帧数据
	*/
	__proto._calculateDatas=function(){
		if (!this._animationData)return;
		var nodes=this._animationData.nodes,i=0,len=nodes.length,tNode;
		this._count=0;
		for (i=0;i < len;i++){
			tNode=nodes[i];
			this._calculateKeyFrames(tNode);
		}
		this._count+=1;
	}

	/**
	*@private
	*计算某个节点的帧数据
	*/
	__proto._calculateKeyFrames=function(node){
		var keyFrames=node.keyframes,key,tKeyFrames,target=node.target;
		if (!node.frames)node.frames={};
		if (!node.keys)node.keys=[];
		else node.keys.length=0;
		if (!node.funkeys)node.funkeys=[];
		else node.funkeys.length=0;
		if (!node.initValues)node.initValues={};
		for (key in keyFrames){
			var isFun=key.indexOf("()")!=-1;
			tKeyFrames=keyFrames[key];
			if (isFun)key=key.substr(0,key.length-2);
			if (!node.frames[key]){
				node.frames[key]=[];
			}
			if (!isFun){
				if (this._targetDic && this._targetDic[target]){
					node.initValues[key]=this._targetDic[target][key];
				}
				tKeyFrames.sort(FrameAnimation._sortIndexFun);
				node.keys.push(key);
				this._calculateNodePropFrames(tKeyFrames,node.frames[key],key,target);
			}
			else{
				node.funkeys.push(key);
				var map=node.frames[key];
				for (var i=0;i < tKeyFrames.length;i++){
					var temp=tKeyFrames[i];
					map[temp.index]=temp.value;
					if (temp.index > this._count)this._count=temp.index;
				}
			}
		}
	}

	/**
	*重置节点，使节点恢复到动画之前的状态，方便其他动画控制
	*/
	__proto.resetNodes=function(){
		if (!this._targetDic)return;
		if (!this._animationData)return;
		var nodes=this._animationData.nodes,i=0,len=nodes.length;
		var tNode;
		var initValues;
		for (i=0;i < len;i++){
			tNode=nodes[i];
			initValues=tNode.initValues;
			if (!initValues)continue ;
			var target=this._targetDic[tNode.target];
			if (!target)continue ;
			var key;
			for (key in initValues){
				target[key]=initValues[key];
			}
		}
	}

	/**
	*@private
	*计算节点某个属性的帧数据
	*/
	__proto._calculateNodePropFrames=function(keyframes,frames,key,target){
		var i=0,len=keyframes.length-1;
		frames.length=keyframes[len].index+1;
		for (i=0;i < len;i++){
			this._dealKeyFrame(keyframes[i]);
			this._calculateFrameValues(keyframes[i],keyframes[i+1],frames);
		}
		if (len==0){
			frames[0]=keyframes[0].value;
			if (this._usedFrames)this._usedFrames[keyframes[0].index]=true;
		}
		this._dealKeyFrame(keyframes[i]);
	}

	/**
	*@private
	*/
	__proto._dealKeyFrame=function(keyFrame){
		if (keyFrame.label && keyFrame.label !="")this.addLabel(keyFrame.label,keyFrame.index);
	}

	/**
	*@private
	*计算两个关键帧直接的帧数据
	*/
	__proto._calculateFrameValues=function(startFrame,endFrame,result){
		var i=0,easeFun;
		var start=startFrame.index,end=endFrame.index;
		var startValue=startFrame.value;
		var dValue=endFrame.value-startFrame.value;
		var dLen=end-start;
		var frames=this._usedFrames;
		if (end > this._count)this._count=end;
		if (startFrame.tween){
			easeFun=Ease[startFrame.tweenMethod];
			if (easeFun==null)easeFun=Ease.linearNone;
			for (i=start;i < end;i++){
				result[i]=easeFun(i-start,startValue,dValue,dLen);
				if (frames)frames[i]=true;
			}
			}else {
			for (i=start;i < end;i++){
				result[i]=startValue;
			}
		}
		if (frames){
			frames[startFrame.index]=true;
			frames[endFrame.index]=true;
		}
		result[endFrame.index]=endFrame.value;
	}

	FrameAnimation._sortIndexFun=null;
	return FrameAnimation;
})(AnimationBase)


//class laya.ui.View extends laya.display.Scene
var View=(function(_super){
	function View(){
		/**@private */
		this._watchMap={};
		/**@private 相对布局组件*/
		this._widget=null;
		/**@private 控件的数据源。 */
		this._dataSource=null;
		this._anchorX=NaN;
		this._anchorY=NaN;
		this._widget=Widget.EMPTY;
		View.__super.call(this);
	}

	__class(View,'laya.ui.View',_super);
	var __proto=View.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		this._watchMap=null;
		_super.prototype.destroy.call(this,destroyChild);
	}

	/**@private */
	__proto.changeData=function(key){
		var arr=this._watchMap[key];
		if (!arr)return;
		for (var i=0,n=arr.length;i < n;i++){
			var watcher=arr[i];
			watcher.exe(this);
		}
	}

	/**@private */
	__proto._sizeChanged=function(){
		if (!isNaN(this._anchorX))this.pivotX=this.anchorX *this.width;
		if (!isNaN(this._anchorY))this.pivotY=this.anchorY *this.height;
		this.event("resize");
	}

	/**
	*@private
	*<p>获取对象的布局样式。请不要直接修改此对象</p>
	*/
	__proto._getWidget=function(){
		this._widget===Widget.EMPTY && (this._widget=this.addComponent(Widget));
		return this._widget;
	}

	/**@private 兼容老版本*/
	__proto.loadUI=function(path){
		var uiView=View.uiMap[path];
		View.uiMap && this.createView(uiView);
	}

	/**X锚点，值为0-1，设置anchorX值最终通过pivotX值来改变节点轴心点。*/
	__getset(0,__proto,'anchorX',function(){
		return this._anchorX;
		},function(value){
		if (this._anchorX !=value){
			this._anchorX=value;
			this.callLater(this._sizeChanged);
		}
	});

	/**
	*<p>在父容器中，此对象的水平方向中轴线与父容器的水平方向中心线的距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'centerX',function(){
		return this._widget.centerX;
		},function(value){
		if (value !=this._widget.centerX){
			this._getWidget().centerX=value;
		}
	});

	/**
	*<p>从组件顶边到其内容区域顶边之间的垂直距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'top',function(){
		return this._widget.top;
		},function(value){
		if (value !=this._widget.top){
			this._getWidget().top=value;
		}
	});

	/**
	*<p>从组件底边到其内容区域底边之间的垂直距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'bottom',function(){
		return this._widget.bottom;
		},function(value){
		if (value !=this._widget.bottom){
			this._getWidget().bottom=value;
		}
	});

	/**@see laya.ui.UIComponent#dataSource*/
	__getset(0,__proto,'dataSource',function(){
		return this._dataSource;
		},function(value){
		this._dataSource=value;
		for (var name in value){
			var comp=this.getChildByName(name);
			if ((comp instanceof laya.ui.UIComponent ))comp.dataSource=value[name];
			else if (this.hasOwnProperty(name)&& !((typeof (this[name])=='function')))this[name]=value[name];
		}
	});

	/**
	*<p>从组件左边到其内容区域左边之间的水平距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'left',function(){
		return this._widget.left;
		},function(value){
		if (value !=this._widget.left){
			this._getWidget().left=value;
		}
	});

	/**
	*<p>从组件右边到其内容区域右边之间的水平距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'right',function(){
		return this._widget.right;
		},function(value){
		if (value !=this._widget.right){
			this._getWidget().right=value;
		}
	});

	/**Y锚点，值为0-1，设置anchorY值最终通过pivotY值来改变节点轴心点。*/
	__getset(0,__proto,'anchorY',function(){
		return this._anchorY;
		},function(value){
		if (this._anchorY !=value){
			this._anchorY=value
			this.callLater(this._sizeChanged);
		}
	});

	/**
	*<p>在父容器中，此对象的垂直方向中轴线与父容器的垂直方向中心线的距离（以像素为单位）。</p>
	*/
	__getset(0,__proto,'centerY',function(){
		return this._widget.centerY;
		},function(value){
		if (value !=this._widget.centerY){
			this._getWidget().centerY=value;
		}
	});

	View.regComponent=function(key,compClass){
		ClassUtils.regClass(key,compClass);
	}

	View.regViewRuntime=function(key,compClass){
		ClassUtils.regClass(key,compClass);
	}

	View.regUI=function(url,json){
		Laya.loader.cacheRes(url,json);
	}

	View.uiMap={};
	View.__init$=function(){
		ClassUtils.regShortClassName([ViewStack,Button,TextArea,ColorPicker,Box,Button,CheckBox,Clip,ComboBox,UIComponent,HScrollBar,HSlider,Image,Label,List,Panel,ProgressBar,Radio,RadioGroup,ScrollBar,Slider,Tab,TextInput,View,Dialog,VScrollBar,VSlider,Tree,HBox,VBox,Sprite,Animation,Text,FontClip]);
	}

	return View;
})(Scene)


//class laya.ui.Box extends laya.ui.UIComponent
var Box=(function(_super){
	function Box(){
		Box.__super.call(this);;
	}

	__class(Box,'laya.ui.Box',_super);
	var __proto=Box.prototype;
	Laya.imps(__proto,{"laya.ui.IBox":true})
	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		for (var name in value){
			var comp=this.getChildByName(name);
			if (comp)comp.dataSource=value[name];
			else if (this.hasOwnProperty(name)&& !((typeof (this[name])=='function')))this[name]=value[name];
		}
	});

	return Box;
})(UIComponent)


//class laya.ui.Button extends laya.ui.UIComponent
var Button=(function(_super){
	function Button(skin,label){
		/**
		*指定按钮按下时是否是切换按钮的显示状态。
		*
		*@example 以下示例代码，创建了一个 <code>Button</code> 实例，并设置为切换按钮。
		*@example
		*package
		*{
			*import laya.ui.Button;
			*import laya.utils.Handler;
			*public class Button_toggle
			*{
				*public function Button_toggle()
				*{
					*Laya.init(640,800);//设置游戏画布宽高、渲染模式。
					*Laya.stage.bgColor="#efefef";//设置画布的背景颜色。
					*Laya.loader.load("resource/ui/button.png",Handler.create(this,onLoadComplete));
					*}
				*private function onLoadComplete():void
				*{
					*trace("资源加载完成！");
					*var button:Button=new Button("resource/ui/button.png","label");//创建一个 Button 实例对象 button ,传入它的皮肤skin和标签label。
					*button.x=100;//设置 button 对象的属性 x 的值，用于控制 button 对象的显示位置。
					*button.y=100;//设置 button 对象的属性 y 的值，用于控制 button 对象的显示位置。
					*button.toggle=true;//设置 button 对象为切换按钮。
					*button.clickHandler=new Handler(this,onClickButton,[button]);//设置 button 的点击事件处理器。
					*Laya.stage.addChild(button);//将此 button 对象添加到显示列表。
					*}
				*private function onClickButton(button:Button):void
				*{
					*trace("button.selected = "+button.selected);
					*}
				*}
			*}
		*@example
		*Laya.init(640,800);//设置游戏画布宽高、渲染模式。
		*Laya.stage.bgColor="#efefef";//设置画布的背景颜色。
		*Laya.loader.load("resource/ui/button.png",laya.utils.Handler.create(this,loadComplete));//加载资源
		*function loadComplete()
		*{
			*console.log("资源加载完成！");
			*var button=new laya.ui.Button("resource/ui/button.png","label");//创建一个 Button 类的实例对象 button ,传入它的皮肤skin和标签label。
			*button.x=100;//设置 button 对象的属性 x 的值，用于控制 button 对象的显示位置。
			*button.y=100;//设置 button 对象的属性 y 的值，用于控制 button 对象的显示位置。
			*button.toggle=true;//设置 button 对象为切换按钮。
			*button.clickHandler=laya.utils.Handler.create(this,onClickButton,[button],false);//设置 button 的点击事件处理器。
			*Laya.stage.addChild(button);//将此 button 对象添加到显示列表。
			*}
		*function onClickButton(button)
		*{
			*console.log("button.selected = ",button.selected);
			*}
		*@example
		*Laya.init(640,800);//设置游戏画布宽高、渲染模式。
		*Laya.stage.bgColor="#efefef";//设置画布的背景颜色。
		*Laya.loader.load("button.png",null,null,null,null,null);//加载资源
		*function loadComplete(){
			*console.log("资源加载完成！");
			*var button:laya.ui.Button=new laya.ui.Button("button.png","label");//创建一个 Button 类的实例对象 button ,传入它的皮肤skin和标签label。
			*button.x=100;//设置 button 对象的属性 x 的值，用于控制 button 对象的显示位置。
			*button.y=100;//设置 button 对象的属性 y 的值，用于控制 button 对象的显示位置。
			*button.toggle=true;//设置 button 对象为切换按钮。
			*button.clickHandler=laya.utils.Handler.create(this,onClickButton,[button],false);//设置 button 的点击事件处理器。
			*Laya.stage.addChild(button);//将此 button 对象添加到显示列表。
			*}
		*function onClickButton(button){
			*console.log("button.selected = ",button.selected);
			*}
		*/
		this.toggle=false;
		/**
		*@private
		*/
		this._bitmap=null;
		/**
		*@private
		*按钮上的文本。
		*/
		this._text=null;
		/**
		*@private
		*按钮文本标签描边的颜色值。
		*/
		this._strokeColors=null;
		/**
		*@private
		*按钮的状态值。
		*/
		this._state=0;
		/**
		*@private
		*表示按钮的选中状态。
		*/
		this._selected=false;
		/**
		*@private
		*按钮的皮肤资源。
		*/
		this._skin=null;
		/**
		*@private
		*指定此显示对象是否自动计算并改变大小等属性。
		*/
		this._autoSize=true;
		/**
		*@private
		*源数据。
		*/
		this._sources=null;
		/**
		*@private
		*按钮的点击事件函数。
		*/
		this._clickHandler=null;
		/**
		*@private
		*/
		this._stateChanged=false;
		Button.__super.call(this);
		this._labelColors=Styles.buttonLabelColors;
		this._stateNum=Styles.buttonStateNum;
		(label===void 0)&& (label="");
		this.skin=skin;
		this.label=label;
	}

	__class(Button,'laya.ui.Button',_super);
	var __proto=Button.prototype;
	Laya.imps(__proto,{"laya.ui.ISelect":true})
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._bitmap && this._bitmap.destroy();
		this._text && this._text.destroy(destroyChild);
		this._bitmap=null;
		this._text=null;
		this._clickHandler=null;
		this._labelColors=this._sources=this._strokeColors=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.graphics=this._bitmap=new AutoBitmap();
	}

	/**@private */
	__proto.createText=function(){
		if (!this._text){
			this._text=new Text();
			this._text.overflow="hidden";
			this._text.align="center";
			this._text.valign="middle";
			this._text.width=this._width;
			this._text.height=this._height;
		}
	}

	/**@inheritDoc */
	__proto.initialize=function(){
		if (this._mouseState!==1){
			this.mouseEnabled=true;
			this._setBit(0x40,true);
		}
		this._createListener("mouseover",this,this.onMouse,null,false,false);
		this._createListener("mouseout",this,this.onMouse,null,false,false);
		this._createListener("mousedown",this,this.onMouse,null,false,false);
		this._createListener("mouseup",this,this.onMouse,null,false,false);
		this._createListener("click",this,this.onMouse,null,false,false);
	}

	/**
	*对象的 <code>Event.MOUSE_OVER、Event.MOUSE_OUT、Event.MOUSE_DOWN、Event.MOUSE_UP、Event.CLICK</code> 事件侦听处理函数。
	*@param e Event 对象。
	*/
	__proto.onMouse=function(e){
		if (this.toggle===false && this._selected)return;
		if (e.type==="click"){
			this.toggle && (this.selected=!this._selected);
			this._clickHandler && this._clickHandler.run();
			return;
		}
		!this._selected && (this.state=Button.stateMap[e.type]);
	}

	__proto._skinLoaded=function(){
		this.callLater(this.changeClips);
		this._setStateChanged();
		this.event("loaded");
	}

	/**
	*@private
	*对象的资源切片发生改变。
	*/
	__proto.changeClips=function(){
		var img=Loader.getRes(this._skin);
		if (!img){
			console.log("lose skin",this._skin);
			return;
		};
		var width=img.sourceWidth;
		var height=img.sourceHeight / this._stateNum;
		img.$_GID || (img.$_GID=Utils.getGID());
		var key=img.$_GID+"-"+this._stateNum;
		var clips=WeakObject.I.get(key);
		if (!Utils.isOkTextureList(clips)){
			clips=null;
		}
		if (clips)this._sources=clips;
		else {
			this._sources=[];
			if (this._stateNum===1){
				this._sources.push(img);
				}else {
				for (var i=0;i < this._stateNum;i++){
					this._sources.push(Texture.createFromTexture(img,0,height *i,width,height));
				}
			}
			WeakObject.I.set(key,this._sources);
		}
		if (this._autoSize){
			this._bitmap.width=this._width || width;
			this._bitmap.height=this._height || height;
			if (this._text){
				this._text.width=this._bitmap.width;
				this._text.height=this._bitmap.height;
			}
			}else {
			this._text && (this._text.x=width);
		}
	}

	/**
	*@inheritDoc
	*/
	__proto.measureWidth=function(){
		this.runCallLater(this.changeClips);
		if (this._autoSize)return this._bitmap.width;
		this.runCallLater(this.changeState);
		return this._bitmap.width+(this._text ? this._text.width :0);
	}

	/**
	*@inheritDoc
	*/
	__proto.measureHeight=function(){
		this.runCallLater(this.changeClips);
		return this._text ? Math.max(this._bitmap.height,this._text.height):this._bitmap.height;
	}

	/**
	*@private
	*改变对象的状态。
	*/
	__proto.changeState=function(){
		this._stateChanged=false;
		this.runCallLater(this.changeClips);
		var index=this._state < this._stateNum ? this._state :this._stateNum-1;
		this._sources && (this._bitmap.source=this._sources[index]);
		if (this.label){
			this._text.color=this._labelColors[index];
			if (this._strokeColors)this._text.strokeColor=this._strokeColors[index];
		}
	}

	/**@private */
	__proto._setStateChanged=function(){
		if (!this._stateChanged){
			this._stateChanged=true;
			this.callLater(this.changeState);
		}
	}

	/**
	*<p>对象的皮肤资源地址。</p>
	*支持单态，两态和三态，用 <code>stateNum</code> 属性设置
	*<p>对象的皮肤地址，以字符串表示。</p>
	*@see #stateNum
	*/
	__getset(0,__proto,'skin',function(){
		return this._skin;
		},function(value){
		if (this._skin !=value){
			this._skin=value;
			if (value){
				if (!Loader.getRes(value)){
					Laya.loader.load(this._skin,Handler.create(this,this._skinLoaded),null,"image",1);
					}else{
					this._skinLoaded();
				}
				}else {
				this._skinLoaded();
			}
		}
	});

	/**
	*表示按钮文本标签的边距。
	*<p><b>格式：</b>"上边距,右边距,下边距,左边距"。</p>
	*/
	__getset(0,__proto,'labelPadding',function(){
		this.createText();
		return this._text.padding.join(",");
		},function(value){
		this.createText();
		this._text.padding=UIUtils.fillArray(Styles.labelPadding,value,Number);
	});

	/**
	*对象的状态值。
	*@see #stateMap
	*/
	__getset(0,__proto,'state',function(){
		return this._state;
		},function(value){
		if (this._state !=value){
			this._state=value;
			this._setStateChanged();
		}
	});

	/**
	*按钮文本标签 <code>Text</code> 控件。
	*/
	__getset(0,__proto,'text',function(){
		this.createText();
		return this._text;
	});

	/**
	*<p>指定对象的状态值，以数字表示。</p>
	*<p>默认值为3。此值决定皮肤资源图片的切割方式。</p>
	*<p><b>取值：</b>
	*<li>1：单态。图片不做切割，按钮的皮肤状态只有一种。</li>
	*<li>2：两态。图片将以竖直方向被等比切割为2部分，从上向下，依次为
	*弹起状态皮肤、
	*按下和经过及选中状态皮肤。</li>
	*<li>3：三态。图片将以竖直方向被等比切割为3部分，从上向下，依次为
	*弹起状态皮肤、
	*经过状态皮肤、
	*按下和选中状态皮肤</li>
	*</p>
	*/
	__getset(0,__proto,'stateNum',function(){
		return this._stateNum;
		},function(value){
		if ((typeof value=='string')){
			value=parseInt(value);
		}
		if (this._stateNum !=value){
			this._stateNum=value < 1 ? 1 :value > 3 ? 3 :value;
			this.callLater(this.changeClips);
		}
	});

	/**
	*按钮的文本内容。
	*/
	__getset(0,__proto,'label',function(){
		return this._text ? this._text.text :null;
		},function(value){
		if (!this._text && !value)return;
		this.createText();
		if (this._text.text !=value){
			value && !this._text.parent && this.addChild(this._text);
			this._text.text=(value+"").replace(/\\n/g,"\n");
			this._setStateChanged();
		}
	});

	/**
	*表示按钮文本标签的字体大小。
	*@see laya.display.Text.fontSize()
	*/
	__getset(0,__proto,'labelSize',function(){
		this.createText();
		return this._text.fontSize;
		},function(value){
		this.createText();
		this._text.fontSize=value
	});

	/**
	*表示按钮的选中状态。
	*<p>如果值为true，表示该对象处于选中状态。否则该对象处于未选中状态。</p>
	*/
	__getset(0,__proto,'selected',function(){
		return this._selected;
		},function(value){
		if (this._selected !=value){
			this._selected=value;
			this.state=this._selected ? 2 :0;
			this.event("change");
		}
	});

	/**
	*表示按钮各个状态下的描边颜色。
	*<p><b>格式:</b> "upColor,overColor,downColor,disableColor"。</p>
	*/
	__getset(0,__proto,'strokeColors',function(){
		return this._strokeColors ? this._strokeColors.join(","):"";
		},function(value){
		this._strokeColors=UIUtils.fillArray(Styles.buttonLabelColors,value,String);
		this._setStateChanged();
	});

	/**
	*表示按钮各个状态下的文本颜色。
	*<p><b>格式:</b> "upColor,overColor,downColor,disableColor"。</p>
	*/
	__getset(0,__proto,'labelColors',function(){
		return this._labelColors.join(",");
		},function(value){
		this._labelColors=UIUtils.fillArray(Styles.buttonLabelColors,value,String);
		this._setStateChanged();
	});

	/**
	*<p>描边宽度（以像素为单位）。</p>
	*默认值0，表示不描边。
	*@see laya.display.Text.stroke()
	*/
	__getset(0,__proto,'labelStroke',function(){
		this.createText();
		return this._text.stroke;
		},function(value){
		this.createText();
		this._text.stroke=value
	});

	/**
	*<p>描边颜色，以字符串表示。</p>
	*默认值为 "#000000"（黑色）;
	*@see laya.display.Text.strokeColor()
	*/
	__getset(0,__proto,'labelStrokeColor',function(){
		this.createText();
		return this._text.strokeColor;
		},function(value){
		this.createText();
		this._text.strokeColor=value
	});

	/**
	*表示按钮文本标签是否为粗体字。
	*@see laya.display.Text.bold()
	*/
	__getset(0,__proto,'labelBold',function(){
		this.createText();
		return this._text.bold;
		},function(value){
		this.createText();
		this._text.bold=value;
	});

	/**
	*表示按钮文本标签的字体名称，以字符串形式表示。
	*@see laya.display.Text.font()
	*/
	__getset(0,__proto,'labelFont',function(){
		this.createText();
		return this._text.font;
		},function(value){
		this.createText();
		this._text.font=value;
	});

	/**标签对齐模式，默认为居中对齐。*/
	__getset(0,__proto,'labelAlign',function(){
		this.createText()
		return this._text.align;
		},function(value){
		this.createText()
		this._text.align=value;
	});

	/**
	*对象的点击事件处理器函数（无默认参数）。
	*/
	__getset(0,__proto,'clickHandler',function(){
		return this._clickHandler;
		},function(value){
		this._clickHandler=value;
	});

	/**
	*<p>当前实例的位图 <code>AutoImage</code> 实例的有效缩放网格数据。</p>
	*<p>数据格式："上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)"，以逗号分隔。
	*<ul><li>例如："4,4,4,4,1"</li></ul></p>
	*@see laya.ui.AutoBitmap.sizeGrid
	*/
	__getset(0,__proto,'sizeGrid',function(){
		if (this._bitmap.sizeGrid)return this._bitmap.sizeGrid.join(",");
		return null;
		},function(value){
		this._bitmap.sizeGrid=UIUtils.fillArray(Styles.defaultSizeGrid,value,Number);
	});

	/**@inheritDoc */
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(UIComponent,this,'width',value);
		if (this._autoSize){
			this._bitmap.width=value;
			this._text && (this._text.width=value);
		}
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(UIComponent,this,'height',value);
		if (this._autoSize){
			this._bitmap.height=value;
			this._text && (this._text.height=value);
		}
	});

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if ((typeof value=='number')|| (typeof value=='string'))this.label=value+"";
		else Laya.superSet(UIComponent,this,'dataSource',value);
	});

	/**图标x,y偏移，格式：100,100*/
	__getset(0,__proto,'iconOffset',function(){
		return this._bitmap._offset ? this._bitmap._offset.join(","):null;
		},function(value){
		if (value)this._bitmap._offset=UIUtils.fillArray([1,1],value,Number);
		else this._bitmap._offset=[];
	});

	__static(Button,
	['stateMap',function(){return this.stateMap={"mouseup":0,"mouseover":1,"mousedown":2,"mouseout":0};}
	]);
	return Button;
})(UIComponent)


//class laya.ui.Clip extends laya.ui.UIComponent
var Clip=(function(_super){
	function Clip(url,clipX,clipY){
		/**@private */
		this._sources=null;
		/**@private */
		this._bitmap=null;
		/**@private */
		this._skin=null;
		/**@private */
		this._clipX=1;
		/**@private */
		this._clipY=1;
		/**@private */
		this._clipWidth=0;
		/**@private */
		this._clipHeight=0;
		/**@private */
		this._autoPlay=false;
		/**@private */
		this._interval=50;
		/**@private */
		this._complete=null;
		/**@private */
		this._isPlaying=false;
		/**@private */
		this._index=0;
		/**@private */
		this._clipChanged=false;
		/**@private */
		this._group=null;
		/**@private */
		this._toIndex=-1;
		Clip.__super.call(this);
		(clipX===void 0)&& (clipX=1);
		(clipY===void 0)&& (clipY=1);
		this._clipX=clipX;
		this._clipY=clipY;
		this.skin=url;
	}

	__class(Clip,'laya.ui.Clip',_super);
	var __proto=Clip.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,true);
		this._bitmap && this._bitmap.destroy();
		this._bitmap=null;
		this._sources=null;
	}

	/**
	*销毁对象并释放加载的皮肤资源。
	*/
	__proto.dispose=function(){
		this.destroy(true);
		Laya.loader.clearRes(this._skin);
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.graphics=this._bitmap=new AutoBitmap();
	}

	/**@private */
	__proto._onDisplay=function(e){
		if (this._isPlaying){
			if (this._getBit(0x80))this.play();
			else this.stop();
			}else if (this._autoPlay){
			this.play();
		}
	}

	__proto._skinLoaded=function(){
		this._setClipChanged();
		this.event("loaded");
	}

	/**
	*@private
	*改变切片的资源、切片的大小。
	*/
	__proto.changeClip=function(){
		this._clipChanged=false;
		if (!this._skin)return;
		var img=Loader.getRes(this._skin);
		if (img){
			this.loadComplete(this._skin,img);
			}else {
			Laya.loader.load(this._skin,Handler.create(this,this.loadComplete,[this._skin]));
		}
	}

	/**
	*@private
	*加载切片图片资源完成函数。
	*@param url 资源地址。
	*@param img 纹理。
	*/
	__proto.loadComplete=function(url,img){
		if (url===this._skin && img){
			var w=this._clipWidth || Math.ceil(img.sourceWidth / this._clipX);
			var h=this._clipHeight || Math.ceil(img.sourceHeight / this._clipY);
			var key=this._skin+w+h;
			var clips=WeakObject.I.get(key);
			if (!Utils.isOkTextureList(clips)){
				clips=null;
			}
			if (clips)this._sources=clips;
			else {
				this._sources=[];
				for (var i=0;i < this._clipY;i++){
					for (var j=0;j < this._clipX;j++){
						this._sources.push(Texture.createFromTexture(img,w *j,h *i,w,h));
					}
				}
				WeakObject.I.set(key,this._sources);
			}
			this.index=this._index;
			this.event("loaded");
			this.onCompResize();
		}
	}

	/**@inheritDoc */
	__proto.measureWidth=function(){
		this.runCallLater(this.changeClip);
		return this._bitmap.width;
	}

	/**@inheritDoc */
	__proto.measureHeight=function(){
		this.runCallLater(this.changeClip);
		return this._bitmap.height;
	}

	/**
	*播放动画。
	*@param from 开始索引
	*@param to 结束索引，-1为不限制
	*/
	__proto.play=function(from,to){
		(from===void 0)&& (from=0);
		(to===void 0)&& (to=-1);
		this._isPlaying=true;
		this.index=from;
		this._toIndex=to;
		this._index++;
		Laya.timer.loop(this.interval,this,this._loop);
		this.on("display",this,this._onDisplay);
		this.on("undisplay",this,this._onDisplay);
	}

	/**
	*@private
	*/
	__proto._loop=function(){
		if (this._visible && this._sources){
			this._index++;
			if (this._toIndex >-1 && this._index >=this._toIndex)this.stop();
			else if (this._index >=this._sources.length)this._index=0;
			this.index=this._index;
		}
	}

	/**
	*停止动画。
	*/
	__proto.stop=function(){
		this._isPlaying=false;
		Laya.timer.clear(this,this._loop);
		this.event("complete");
	}

	/**@private */
	__proto._setClipChanged=function(){
		if (!this._clipChanged){
			this._clipChanged=true;
			this.callLater(this.changeClip);
		}
	}

	/**
	*表示动画播放间隔时间(以毫秒为单位)。
	*/
	__getset(0,__proto,'interval',function(){
		return this._interval;
		},function(value){
		if (this._interval !=value){
			this._interval=value;
			if (this._isPlaying)this.play();
		}
	});

	/**
	*@copy laya.ui.Image#skin
	*/
	__getset(0,__proto,'skin',function(){
		return this._skin;
		},function(value){
		if (this._skin !=value){
			this._skin=value;
			if (value){
				if(!Loader.getRes(value)){
					Laya.loader.load(this._skin,Handler.create(this,this._skinLoaded),null,"image",1);
					}else{
					this._skinLoaded();
				}
				}else {
				this._bitmap.source=null;
			}
		}
	});

	/**
	*源数据。
	*/
	__getset(0,__proto,'sources',function(){
		return this._sources;
		},function(value){
		this._sources=value;
		this.index=this._index;
		this.event("loaded");
	});

	/**X轴（横向）切片数量。*/
	__getset(0,__proto,'clipX',function(){
		return this._clipX;
		},function(value){
		this._clipX=value || 1;
		this._setClipChanged()
	});

	/**Y轴(竖向)切片数量。*/
	__getset(0,__proto,'clipY',function(){
		return this._clipY;
		},function(value){
		this._clipY=value || 1;
		this._setClipChanged()
	});

	/**
	*切片动画的总帧数。
	*/
	__getset(0,__proto,'total',function(){
		this.runCallLater(this.changeClip);
		return this._sources ? this._sources.length :0;
	});

	/**
	*横向分割时每个切片的宽度，与 <code>clipX</code> 同时设置时优先级高于 <code>clipX</code> 。
	*/
	__getset(0,__proto,'clipWidth',function(){
		return this._clipWidth;
		},function(value){
		this._clipWidth=value;
		this._setClipChanged()
	});

	/**
	*<p>当前实例的位图 <code>AutoImage</code> 实例的有效缩放网格数据。</p>
	*<p>数据格式："上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)"，以逗号分隔。
	*<ul><li>例如："4,4,4,4,1"</li></ul></p>
	*@see laya.ui.AutoBitmap.sizeGrid
	*/
	__getset(0,__proto,'sizeGrid',function(){
		if (this._bitmap.sizeGrid)return this._bitmap.sizeGrid.join(",");
		return null;
		},function(value){
		this._bitmap.sizeGrid=UIUtils.fillArray(Styles.defaultSizeGrid,value,Number);
	});

	/**
	*资源分组。
	*/
	__getset(0,__proto,'group',function(){
		return this._group;
		},function(value){
		if (value && this._skin)Loader.setGroup(this._skin,value);
		this._group=value;
	});

	/**
	*竖向分割时每个切片的高度，与 <code>clipY</code> 同时设置时优先级高于 <code>clipY</code> 。
	*/
	__getset(0,__proto,'clipHeight',function(){
		return this._clipHeight;
		},function(value){
		this._clipHeight=value;
		this._setClipChanged()
	});

	/**@inheritDoc */
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(UIComponent,this,'width',value);
		this._bitmap.width=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(UIComponent,this,'height',value);
		this._bitmap.height=value;
	});

	/**
	*当前帧索引。
	*/
	__getset(0,__proto,'index',function(){
		return this._index;
		},function(value){
		this._index=value;
		this._bitmap && this._sources && (this._bitmap.source=this._sources[value]);
		this.event("change");
	});

	/**
	*表示是否自动播放动画，若自动播放值为true,否则值为false;
	*<p>可控制切片动画的播放、停止。</p>
	*/
	__getset(0,__proto,'autoPlay',function(){
		return this._autoPlay;
		},function(value){
		if (this._autoPlay !=value){
			this._autoPlay=value;
			value ? this.play():this.stop();
		}
	});

	/**
	*表示动画的当前播放状态。
	*如果动画正在播放中，则为true，否则为flash。
	*/
	__getset(0,__proto,'isPlaying',function(){
		return this._isPlaying;
		},function(value){
		this._isPlaying=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if (((typeof value=='number')&& Math.floor(value)==value)|| (typeof value=='string'))this.index=parseInt(value);
		else Laya.superSet(UIComponent,this,'dataSource',value);
	});

	/**
	*<code>AutoBitmap</code> 位图实例。
	*/
	__getset(0,__proto,'bitmap',function(){
		return this._bitmap;
	});

	return Clip;
})(UIComponent)


//class laya.ui.ColorPicker extends laya.ui.UIComponent
var ColorPicker=(function(_super){
	function ColorPicker(){
		/**
		*当颜色发生改变时执行的函数处理器。
		*默认返回参数color：颜色值字符串。
		*/
		this.changeHandler=null;
		/**
		*@private
		*指定每个正方形的颜色小格子的宽高（以像素为单位）。
		*/
		this._gridSize=11;
		/**
		*@private
		*表示颜色样本列表面板的背景颜色值。
		*/
		this._bgColor="#ffffff";
		/**
		*@private
		*表示颜色样本列表面板的边框颜色值。
		*/
		this._borderColor="#000000";
		/**
		*@private
		*表示颜色样本列表面板选择或输入的颜色值。
		*/
		this._inputColor="#000000";
		/**
		*@private
		*表示颜色输入框的背景颜色值。
		*/
		this._inputBgColor="#efefef";
		/**
		*@private
		*表示颜色样本列表面板。
		*/
		this._colorPanel=null;
		/**
		*@private
		*表示颜色网格。
		*/
		this._colorTiles=null;
		/**
		*@private
		*表示颜色块显示对象。
		*/
		this._colorBlock=null;
		/**
		*@private
		*表示颜色输入框控件 <code>Input</code> 。
		*/
		this._colorInput=null;
		/**
		*@private
		*表示点击后显示颜色样本列表面板的按钮控件 <code>Button</code> 。
		*/
		this._colorButton=null;
		/**
		*@private
		*表示颜色值列表。
		*/
		this._colors=[];
		/**
		*@private
		*表示选择的颜色值。
		*/
		this._selectedColor="#000000";
		/**@private */
		this._panelChanged=false;
		ColorPicker.__super.call(this);
	}

	__class(ColorPicker,'laya.ui.ColorPicker',_super);
	var __proto=ColorPicker.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._colorPanel && this._colorPanel.destroy(destroyChild);
		this._colorButton && this._colorButton.destroy(destroyChild);
		this._colorPanel=null;
		this._colorTiles=null;
		this._colorBlock=null;
		this._colorInput=null;
		this._colorButton=null;
		this._colors=null;
		this.changeHandler=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this._colorButton=new Button());
		this._colorPanel=new Box();
		this._colorPanel.size(230,166);
		this._colorPanel.addChild(this._colorTiles=new Sprite());
		this._colorPanel.addChild(this._colorBlock=new Sprite());
		this._colorPanel.addChild(this._colorInput=new Input());
	}

	/**@inheritDoc */
	__proto.initialize=function(){
		this._colorButton.on("click",this,this.onColorButtonClick);
		this._colorBlock.pos(5,5);
		this._colorInput.pos(60,5);
		this._colorInput.size(60,20);
		this._colorInput.on("change",this,this.onColorInputChange);
		this._colorInput.on("keydown",this,this.onColorFieldKeyDown);
		this._colorTiles.pos(5,30);
		this._colorTiles.on("mousemove",this,this.onColorTilesMouseMove);
		this._colorTiles.on("click",this,this.onColorTilesClick);
		this._colorTiles.size(20 *this._gridSize,12 *this._gridSize);
		this._colorPanel.on("mousedown",this,this.onPanelMouseDown);
		this.bgColor=this._bgColor;
	}

	__proto.onPanelMouseDown=function(e){
		e.stopPropagation();
	}

	/**
	*改变颜色样本列表面板。
	*/
	__proto.changePanel=function(){
		this._panelChanged=false;
		var g=this._colorPanel.graphics;
		g.clear(true);
		g.drawRect(0,0,230,166,this._bgColor,this._borderColor);
		this.drawBlock(this._selectedColor);
		this._colorInput.borderColor=this._borderColor;
		this._colorInput.bgColor=this._inputBgColor;
		this._colorInput.color=this._inputColor;
		g=this._colorTiles.graphics;
		g.clear(true);
		var mainColors=[0x000000,0x333333,0x666666,0x999999,0xCCCCCC,0xFFFFFF,0xFF0000,0x00FF00,0x0000FF,0xFFFF00,0x00FFFF,0xFF00FF];
		for (var i=0;i < 12;i++){
			for (var j=0;j < 20;j++){
				var color=0;
				if (j===0)color=mainColors[i];
				else if (j===1)color=0x000000;
				else color=(((i *3+j / 6)% 3 << 0)+((i / 6)<< 0)*3)*0x33 << 16 | j % 6 *0x33 << 8 | (i << 0)% 6 *0x33;
				var strColor=UIUtils.toColor(color);
				this._colors.push(strColor);
				var x=j *this._gridSize;
				var y=i *this._gridSize;
				g.drawRect(x,y,this._gridSize,this._gridSize,strColor,"#000000");
			}
		}
	}

	/**
	*颜色样本列表面板的显示按钮的 <code>Event.MOUSE_DOWN</code> 事件侦听处理函数。
	*/
	__proto.onColorButtonClick=function(e){
		if (this._colorPanel.parent)this.close();
		else this.open();
	}

	/**
	*打开颜色样本列表面板。
	*/
	__proto.open=function(){
		var p=this.localToGlobal(new Point());
		var px=p.x+this._colorPanel.width <=Laya.stage.width ? p.x :Laya.stage.width-this._colorPanel.width;
		var py=p.y+this._colorButton.height;
		py=py+this._colorPanel.height <=Laya.stage.height ? py :p.y-this._colorPanel.height;
		this._colorPanel.pos(px,py);
		this._colorPanel.zOrder=1001;
		Laya._currentStage.addChild(this._colorPanel);
		Laya.stage.on("mousedown",this,this.removeColorBox);
	}

	/**
	*关闭颜色样本列表面板。
	*/
	__proto.close=function(){
		Laya.stage.off("mousedown",this,this.removeColorBox);
		this._colorPanel.removeSelf();
	}

	/**
	*舞台的 <code>Event.MOUSE_DOWN</code> 事件侦听处理函数。
	*/
	__proto.removeColorBox=function(e){
		this.close();
	}

	/**
	*小格子色块的 <code>Event.KEY_DOWN</code> 事件侦听处理函数。
	*/
	__proto.onColorFieldKeyDown=function(e){
		if (e.keyCode==13){
			if (this._colorInput.text)this.selectedColor=this._colorInput.text;
			else this.selectedColor=null;
			this.close();
			e.stopPropagation();
		}
	}

	/**
	*颜色值输入框 <code>Event.CHANGE</code> 事件侦听处理函数。
	*/
	__proto.onColorInputChange=function(e){
		if (this._colorInput.text)this.drawBlock(this._colorInput.text);
		else this.drawBlock("#FFFFFF");
	}

	/**
	*小格子色块的 <code>Event.CLICK</code> 事件侦听处理函数。
	*/
	__proto.onColorTilesClick=function(e){
		this.selectedColor=this.getColorByMouse();
		this.close();
	}

	/**
	*@private
	*小格子色块的 <code>Event.MOUSE_MOVE</code> 事件侦听处理函数。
	*/
	__proto.onColorTilesMouseMove=function(e){
		this._colorInput.focus=false;
		var color=this.getColorByMouse();
		this._colorInput.text=color;
		this.drawBlock(color);
	}

	/**
	*通过鼠标位置取对应的颜色块的颜色值。
	*/
	__proto.getColorByMouse=function(){
		var point=this._colorTiles.getMousePoint();
		var x=Math.floor(point.x / this._gridSize);
		var y=Math.floor(point.y / this._gridSize);
		return this._colors[y *20+x];
	}

	/**
	*绘制颜色块。
	*@param color 需要绘制的颜色块的颜色值。
	*/
	__proto.drawBlock=function(color){
		var g=this._colorBlock.graphics;
		g.clear(true);
		var showColor=color ? color :"#ffffff";
		g.drawRect(0,0,50,20,showColor,this._borderColor);
		color || g.drawLine(0,0,50,20,"#ff0000");
	}

	/**
	*改变颜色。
	*/
	__proto.changeColor=function(){
		var g=this.graphics;
		g.clear(true);
		var showColor=this._selectedColor || "#000000";
		g.drawRect(0,0,this._colorButton.width,this._colorButton.height,showColor);
	}

	/**@private */
	__proto._setPanelChanged=function(){
		if (!this._panelChanged){
			this._panelChanged=true;
			this.callLater(this.changePanel);
		}
	}

	/**
	*表示颜色输入框的背景颜色值。
	*/
	__getset(0,__proto,'inputBgColor',function(){
		return this._inputBgColor;
		},function(value){
		this._inputBgColor=value;
		this._setPanelChanged();
	});

	/**
	*表示选择的颜色值。
	*/
	__getset(0,__proto,'selectedColor',function(){
		return this._selectedColor;
		},function(value){
		if (this._selectedColor !=value){
			this._selectedColor=this._colorInput.text=value;
			this.drawBlock(value);
			this.changeColor();
			this.changeHandler && this.changeHandler.runWith(this._selectedColor);
			this.event("change",Event.EMPTY.setTo("change",this,this));
		}
	});

	/**
	*@copy laya.ui.Button#skin
	*/
	__getset(0,__proto,'skin',function(){
		return this._colorButton.skin;
		},function(value){
		this._colorButton.once("loaded",this,this.changeColor);
		this._colorButton.skin=value;
	});

	/**
	*表示颜色样本列表面板的背景颜色值。
	*/
	__getset(0,__proto,'bgColor',function(){
		return this._bgColor;
		},function(value){
		this._bgColor=value;
		this._setPanelChanged();
	});

	/**
	*表示颜色样本列表面板的边框颜色值。
	*/
	__getset(0,__proto,'borderColor',function(){
		return this._borderColor;
		},function(value){
		this._borderColor=value;
		this._setPanelChanged();
	});

	/**
	*表示颜色样本列表面板选择或输入的颜色值。
	*/
	__getset(0,__proto,'inputColor',function(){
		return this._inputColor;
		},function(value){
		this._inputColor=value;
		this._setPanelChanged();
	});

	return ColorPicker;
})(UIComponent)


//class laya.ui.ComboBox extends laya.ui.UIComponent
var ComboBox=(function(_super){
	function ComboBox(skin,labels){
		/**@private */
		this._visibleNum=6;
		/**
		*@private
		*/
		this._button=null;
		/**
		*@private
		*/
		this._list=null;
		/**
		*@private
		*/
		this._isOpen=false;
		/**
		*@private
		*/
		this._itemSize=12;
		/**
		*@private
		*/
		this._labels=[];
		/**
		*@private
		*/
		this._selectedIndex=-1;
		/**
		*@private
		*/
		this._selectHandler=null;
		/**
		*@private
		*/
		this._itemHeight=NaN;
		/**
		*@private
		*/
		this._listHeight=NaN;
		/**
		*@private
		*/
		this._listChanged=false;
		/**
		*@private
		*/
		this._itemChanged=false;
		/**
		*@private
		*/
		this._scrollBarSkin=null;
		/**
		*@private
		*/
		this._isCustomList=false;
		/**
		*渲染项，用来显示下拉列表展示对象
		*/
		this.itemRender=null;
		ComboBox.__super.call(this);
		this._itemColors=Styles.comboBoxItemColors;
		this.skin=skin;
		this.labels=labels;
	}

	__class(ComboBox,'laya.ui.ComboBox',_super);
	var __proto=ComboBox.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._button && this._button.destroy(destroyChild);
		this._list && this._list.destroy(destroyChild);
		this._button=null;
		this._list=null;
		this._itemColors=null;
		this._labels=null;
		this._selectHandler=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this._button=new Button());
		this._button.text.align="left";
		this._button.labelPadding="0,0,0,5";
		this._button.on("mousedown",this,this.onButtonMouseDown);
	}

	__proto._createList=function(){
		this._list=new List();
		if (this._scrollBarSkin)this._list.vScrollBarSkin=this._scrollBarSkin;
		this._setListEvent(this._list);
	}

	__proto._setListEvent=function(list){
		this._list.selectEnable=true;
		this._list.on("mousedown",this,this.onListDown);
		this._list.mouseHandler=Handler.create(this,this.onlistItemMouse,null,false);
		if (this._list.scrollBar)this._list.scrollBar.on("mousedown",this,this.onScrollBarDown);
	}

	/**
	*@private
	*/
	__proto.onListDown=function(e){
		e.stopPropagation();
	}

	__proto.onScrollBarDown=function(e){
		e.stopPropagation();
	}

	__proto.onButtonMouseDown=function(e){
		this.callLater(this.switchTo,[!this._isOpen]);
	}

	/**@inheritDoc */
	__proto.measureWidth=function(){
		return this._button.width;
	}

	/**@inheritDoc */
	__proto.measureHeight=function(){
		return this._button.height;
	}

	/**
	*@private
	*/
	__proto.changeList=function(){
		this._listChanged=false;
		var labelWidth=this.width-2;
		var labelColor=this._itemColors[2];
		this._itemHeight=this._itemSize+6;
		this._list.itemRender=this.itemRender || {type:"Box",child:[{type:"Label",props:{name:"label",x:1,padding:"3,3,3,3",width:labelWidth,height:this._itemHeight,fontSize:this._itemSize,color:labelColor}}]};
		this._list.repeatY=this._visibleNum;
		this._list.refresh();
	}

	/**
	*@private
	*下拉列表的鼠标事件响应函数。
	*/
	__proto.onlistItemMouse=function(e,index){
		var type=e.type;
		if (type==="mouseover" || type==="mouseout"){
			if (this._isCustomList)return;
			var box=this._list.getCell(index);
			if (!box)return;
			var label=box.getChildByName("label");
			if (label){
				if (type==="mouseover"){
					label.bgColor=this._itemColors[0];
					label.color=this._itemColors[1];
					}else {
					label.bgColor=null;
					label.color=this._itemColors[2];
				}
			}
			}else if (type==="click"){
			this.selectedIndex=index;
			this.isOpen=false;
		}
	}

	/**
	*@private
	*/
	__proto.switchTo=function(value){
		this.isOpen=value;
	}

	/**
	*更改下拉列表的打开状态。
	*/
	__proto.changeOpen=function(){
		this.isOpen=!this._isOpen;
	}

	/**
	*更改下拉列表。
	*/
	__proto.changeItem=function(){
		this._itemChanged=false;
		this._listHeight=this._labels.length > 0 ? Math.min(this._visibleNum,this._labels.length)*this._itemHeight :this._itemHeight;
		if (!this._isCustomList){
			var g=this._list.graphics;
			g.clear(true);
			g.drawRect(0,0,this.width-1,this._listHeight,this._itemColors[4],this._itemColors[3]);
		};
		var a=this._list.array || [];
		a.length=0;
		for (var i=0,n=this._labels.length;i < n;i++){
			a.push({label:this._labels[i]});
		}
		this._list.height=this._listHeight;
		this._list.array=a;
	}

	__proto.changeSelected=function(){
		this._button.label=this.selectedLabel;
	}

	__proto._onStageMouseWheel=function(e){
		if(!this._list||this._list.contains(e.target))return;
		this.removeList(null);
	}

	/**
	*关闭下拉列表。
	*/
	__proto.removeList=function(e){
		Laya.stage.off("mousedown",this,this.removeList);
		Laya.stage.off("mousewheel",this,this._onStageMouseWheel);
		this.isOpen=false;
	}

	/**
	*表示选择的下拉列表项的索引。
	*/
	__getset(0,__proto,'selectedIndex',function(){
		return this._selectedIndex;
		},function(value){
		if (this._selectedIndex !=value){
			this._selectedIndex=value;
			if (this._labels.length > 0)this.changeSelected();
			else this.callLater(this.changeSelected);
			this.event("change",[Event.EMPTY.setTo("change",this,this)]);
			this._selectHandler && this._selectHandler.runWith(this._selectedIndex);
		}
	});

	/**
	*@copy laya.ui.Button#skin
	*/
	__getset(0,__proto,'skin',function(){
		return this._button.skin;
		},function(value){
		if (this._button.skin !=value){
			this._button.skin=value;
			this._listChanged=true;
		}
	});

	/**
	*获取或设置没有滚动条的下拉列表中可显示的最大行数。
	*/
	__getset(0,__proto,'visibleNum',function(){
		return this._visibleNum;
		},function(value){
		this._visibleNum=value;
		this._listChanged=true;
	});

	/**@inheritDoc */
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(UIComponent,this,'width',value);
		this._button.width=this._width;
		this._itemChanged=true;
		this._listChanged=true;
	});

	/**
	*表示选择的下拉列表项的的标签。
	*/
	__getset(0,__proto,'selectedLabel',function(){
		return this._selectedIndex >-1 && this._selectedIndex < this._labels.length ? this._labels[this._selectedIndex] :null;
		},function(value){
		this.selectedIndex=this._labels.indexOf(value);
	});

	/**
	*标签集合字符串。
	*/
	__getset(0,__proto,'labels',function(){
		return this._labels.join(",");
		},function(value){
		if (this._labels.length > 0)this.selectedIndex=-1;
		if (value)this._labels=value.split(",");
		else this._labels.length=0;
		this._itemChanged=true;
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(UIComponent,this,'height',value);
		this._button.height=this._height;
	});

	/**
	*改变下拉列表的选择项时执行的处理器(默认返回参数index:int)。
	*/
	__getset(0,__proto,'selectHandler',function(){
		return this._selectHandler;
		},function(value){
		this._selectHandler=value;
	});

	/**
	*表示按钮文本标签是否为粗体字。
	*@see laya.display.Text#bold
	*/
	__getset(0,__proto,'labelBold',function(){
		return this._button.text.bold;
		},function(value){
		this._button.text.bold=value
	});

	/**
	*下拉列表项颜色。
	*<p><b>格式：</b>"悬停或被选中时背景颜色,悬停或被选中时标签颜色,标签颜色,边框颜色,背景颜色"</p>
	*/
	__getset(0,__proto,'itemColors',function(){
		return String(this._itemColors)
		},function(value){
		this._itemColors=UIUtils.fillArray(this._itemColors,value,String);
		this._listChanged=true;
	});

	/**
	*下拉列表项标签的字体大小。
	*/
	__getset(0,__proto,'itemSize',function(){
		return this._itemSize;
		},function(value){
		this._itemSize=value;
		this._listChanged=true;
	});

	/**
	*获取对 <code>ComboBox</code> 组件所包含的 <code>VScrollBar</code> 滚动条组件的引用。
	*/
	__getset(0,__proto,'scrollBar',function(){
		return this.list.scrollBar;
	});

	/**
	*表示下拉列表的打开状态。
	*/
	__getset(0,__proto,'isOpen',function(){
		return this._isOpen;
		},function(value){
		if (this._isOpen !=value){
			this._isOpen=value;
			this._button.selected=this._isOpen;
			if (this._isOpen){
				this._list || this._createList();
				this._listChanged && !this._isCustomList && this.changeList();
				this._itemChanged && this.changeItem();
				var p=this.localToGlobal(Point.TEMP.setTo(0,0));
				var py=p.y+this._button.height;
				py=py+this._listHeight <=Laya.stage.height ? py :p.y-this._listHeight;
				this._list.pos(p.x,py);
				this._list.zOrder=1001;
				Laya._currentStage.addChild(this._list);
				Laya.stage.once("mousedown",this,this.removeList);
				Laya.stage.on("mousewheel",this,this._onStageMouseWheel);
				this._list.selectedIndex=this._selectedIndex;
				}else {
				this._list && this._list.removeSelf();
			}
		}
	});

	/**
	*滚动条皮肤。
	*/
	__getset(0,__proto,'scrollBarSkin',function(){
		return this._scrollBarSkin;
		},function(value){
		this._scrollBarSkin=value;
	});

	/**
	*<p>当前实例的位图 <code>AutoImage</code> 实例的有效缩放网格数据。</p>
	*<p>数据格式："上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)"，以逗号分隔。
	*<ul><li>例如："4,4,4,4,1"</li></ul></p>
	*@see laya.ui.AutoBitmap.sizeGrid
	*/
	__getset(0,__proto,'sizeGrid',function(){
		return this._button.sizeGrid;
		},function(value){
		this._button.sizeGrid=value;
	});

	/**
	*获取对 <code>ComboBox</code> 组件所包含的 <code>Button</code> 组件的引用。
	*/
	__getset(0,__proto,'button',function(){
		return this._button;
	});

	/**
	*获取对 <code>ComboBox</code> 组件所包含的 <code>List</code> 列表组件的引用。
	*/
	__getset(0,__proto,'list',function(){
		this._list || this._createList();
		return this._list;
		},function(value){
		if (value){
			value.removeSelf();
			this._isCustomList=true;
			this._list=value;
			this._setListEvent(value);
			this._itemHeight=value.getCell(0).height+value.spaceY;
		}
	});

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if (((typeof value=='number')&& Math.floor(value)==value)|| (typeof value=='string'))this.selectedIndex=parseInt(value);
		else if ((value instanceof Array))this.labels=(value).join(",");
		else Laya.superSet(UIComponent,this,'dataSource',value);
	});

	/**
	*获取或设置对 <code>ComboBox</code> 组件所包含的 <code>Button</code> 组件的文本标签颜色。
	*<p><b>格式：</b>upColor,overColor,downColor,disableColor</p>
	*/
	__getset(0,__proto,'labelColors',function(){
		return this._button.labelColors;
		},function(value){
		if (this._button.labelColors !=value){
			this._button.labelColors=value;
		}
	});

	/**
	*获取或设置对 <code>ComboBox</code> 组件所包含的 <code>Button</code> 组件的文本边距。
	*<p><b>格式：</b>上边距,右边距,下边距,左边距</p>
	*/
	__getset(0,__proto,'labelPadding',function(){
		return this._button.text.padding.join(",");
		},function(value){
		this._button.text.padding=UIUtils.fillArray(Styles.labelPadding,value,Number);
	});

	/**
	*获取或设置对 <code>ComboBox</code> 组件所包含的 <code>Button</code> 组件的标签字体大小。
	*/
	__getset(0,__proto,'labelSize',function(){
		return this._button.text.fontSize;
		},function(value){
		this._button.text.fontSize=value
	});

	/**
	*表示按钮文本标签的字体名称，以字符串形式表示。
	*@see laya.display.Text#font
	*/
	__getset(0,__proto,'labelFont',function(){
		return this._button.text.font;
		},function(value){
		this._button.text.font=value
	});

	/**
	*表示按钮的状态值。
	*@see laya.ui.Button#stateNum
	*/
	__getset(0,__proto,'stateNum',function(){
		return this._button.stateNum;
		},function(value){
		this._button.stateNum=value
	});

	return ComboBox;
})(UIComponent)


//class laya.ui.ScrollBar extends laya.ui.UIComponent
var ScrollBar=(function(_super){
	function ScrollBar(skin){
		/**滚动衰减系数*/
		this.rollRatio=0.95;
		/**滚动变化时回调，回传value参数。*/
		this.changeHandler=null;
		/**是否缩放滑动条，默认值为true。 */
		this.scaleBar=true;
		/**一个布尔值，指定是否自动隐藏滚动条(无需滚动时)，默认值为false。*/
		this.autoHide=false;
		/**橡皮筋效果极限距离，0为没有橡皮筋效果。*/
		this.elasticDistance=0;
		/**橡皮筋回弹时间，单位为毫秒。*/
		this.elasticBackTime=500;
		/**上按钮 */
		this.upButton=null;
		/**下按钮 */
		this.downButton=null;
		/**滑条 */
		this.slider=null;
		/**@private */
		this._scrollSize=1;
		/**@private */
		this._skin=null;
		/**@private */
		this._thumbPercent=1;
		/**@private */
		this._target=null;
		/**@private */
		this._lastPoint=null;
		/**@private */
		this._lastOffset=0;
		/**@private */
		this._checkElastic=false;
		/**@private */
		this._isElastic=false;
		/**@private */
		this._value=NaN;
		/**@private */
		this._hide=false;
		/**@private */
		this._clickOnly=true;
		/**@private */
		this._offsets=null;
		ScrollBar.__super.call(this);
		this._showButtons=UIConfig.showButtons;
		this._touchScrollEnable=UIConfig.touchScrollEnable;
		this._mouseWheelEnable=UIConfig.mouseWheelEnable;
		this.skin=skin;
		this.max=1;
	}

	__class(ScrollBar,'laya.ui.ScrollBar',_super);
	var __proto=ScrollBar.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		this.stopScroll();
		this.target=null;
		_super.prototype.destroy.call(this,destroyChild);
		this.upButton && this.upButton.destroy(destroyChild);
		this.downButton && this.downButton.destroy(destroyChild);
		this.slider && this.slider.destroy(destroyChild);
		this.upButton=this.downButton=null;
		this.slider=null;
		this.changeHandler=null;
		this._offsets=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this.slider=new Slider());
		this.addChild(this.upButton=new Button());
		this.addChild(this.downButton=new Button());
	}

	/**@inheritDoc */
	__proto.initialize=function(){
		this.slider.showLabel=false;
		this.slider.on("change",this,this.onSliderChange);
		this.slider.setSlider(0,0,0);
		this.upButton.on("mousedown",this,this.onButtonMouseDown);
		this.downButton.on("mousedown",this,this.onButtonMouseDown);
	}

	/**
	*@private
	*滑块位置发生改变的处理函数。
	*/
	__proto.onSliderChange=function(){
		if(this._value !=this.slider.value)this.value=this.slider.value;
	}

	/**
	*@private
	*向上和向下按钮的 <code>Event.MOUSE_DOWN</code> 事件侦听处理函数。
	*/
	__proto.onButtonMouseDown=function(e){
		var isUp=e.currentTarget===this.upButton;
		this.slide(isUp);
		Laya.timer.once(Styles.scrollBarDelayTime,this,this.startLoop,[isUp]);
		Laya.stage.once("mouseup",this,this.onStageMouseUp);
	}

	/**@private */
	__proto.startLoop=function(isUp){
		Laya.timer.frameLoop(1,this,this.slide,[isUp]);
	}

	/**@private */
	__proto.slide=function(isUp){
		if (isUp)this.value-=this._scrollSize;
		else this.value+=this._scrollSize;
	}

	/**
	*@private
	*舞台的 <code>Event.MOUSE_DOWN</code> 事件侦听处理函数。
	*/
	__proto.onStageMouseUp=function(e){
		Laya.timer.clear(this,this.startLoop);
		Laya.timer.clear(this,this.slide);
	}

	__proto._skinLoaded=function(){
		this.slider.skin=this._skin;
		this.callLater(this.changeScrollBar);
		this.event("loaded");
	}

	/**
	*@private
	*更改对象的皮肤及位置。
	*/
	__proto.changeScrollBar=function(){
		this.upButton.visible=this._showButtons;
		this.downButton.visible=this._showButtons;
		if (this._showButtons){
			this.upButton.skin=this._skin.replace(".png","$up.png");
			this.downButton.skin=this._skin.replace(".png","$down.png");
		}
		if (this.slider.isVertical)this.slider.y=this._showButtons ? this.upButton.height :0;
		else this.slider.x=this._showButtons ? this.upButton.width :0;
		this.resetPositions();
		this.repaint();
	}

	/**@inheritDoc */
	__proto._sizeChanged=function(){
		_super.prototype._sizeChanged.call(this);
		this.repaint();
		this.resetPositions();
		this.event("change");
		this.changeHandler && this.changeHandler.runWith(this.value);
	}

	/**@private */
	__proto.resetPositions=function(){
		if (this.slider.isVertical)this.slider.height=this.height-(this._showButtons ? (this.upButton.height+this.downButton.height):0);
		else this.slider.width=this.width-(this._showButtons ? (this.upButton.width+this.downButton.width):0);
		this.resetButtonPosition();
	}

	/**@private */
	__proto.resetButtonPosition=function(){
		if (this.slider.isVertical)this.downButton.y=this.slider._y+this.slider.height;
		else this.downButton.x=this.slider._x+this.slider.width;
	}

	/**@inheritDoc */
	__proto.measureWidth=function(){
		if (this.slider.isVertical)return this.slider.width;
		return 100;
	}

	/**@inheritDoc */
	__proto.measureHeight=function(){
		if (this.slider.isVertical)return 100;
		return this.slider.height;
	}

	/**
	*设置滚动条信息。
	*@param min 滚动条最小位置值。
	*@param max 滚动条最大位置值。
	*@param value 滚动条当前位置值。
	*/
	__proto.setScroll=function(min,max,value){
		this.runCallLater(this._sizeChanged);
		this.slider.setSlider(min,max,value);
		this.slider.bar.visible=max > 0;
		if (!this._hide && this.autoHide)this.visible=false;
	}

	/**@private */
	__proto.onTargetMouseWheel=function(e){
		this.value-=e.delta *this._scrollSize;
		this.target=this._target;
	}

	/**@private */
	__proto.onTargetMouseDown=function(e){
		this._clickOnly=true;
		this._lastOffset=0;
		this._checkElastic=false;
		this._lastPoint || (this._lastPoint=new Point());
		this._lastPoint.setTo(Laya.stage.mouseX,Laya.stage.mouseY);
		Laya.timer.clear(this,this.tweenMove);
		Tween.clearTween(this);
		Laya.stage.once("mouseup",this,this.onStageMouseUp2);
		Laya.stage.once("mouseout",this,this.onStageMouseUp2);
		Laya.timer.frameLoop(1,this,this.loop);
	}

	/**@private */
	__proto.loop=function(){
		var mouseY=Laya.stage.mouseY;
		var mouseX=Laya.stage.mouseX;
		this._lastOffset=this.isVertical ? (mouseY-this._lastPoint.y):(mouseX-this._lastPoint.x);
		if (this._clickOnly){
			if (Math.abs(this._lastOffset *(this.isVertical ? Laya.stage._canvasTransform.getScaleY():Laya.stage._canvasTransform.getScaleX()))> 1){
				this._clickOnly=false;
				this._offsets || (this._offsets=[]);
				this._offsets.length=0;
				this._target.mouseEnabled=false;
				if (!this.hide && this.autoHide){
					this.alpha=1;
					this.visible=true;
				}
				this.event("start");
			}else return;
		}
		this._offsets.push(this._lastOffset);
		this._lastPoint.x=mouseX;
		this._lastPoint.y=mouseY;
		if (this._lastOffset===0)return;
		if (!this._checkElastic){
			if (this.elasticDistance > 0){
				if (!this._checkElastic && this._lastOffset !=0){
					if ((this._lastOffset > 0 && this._value <=this.min)|| (this._lastOffset < 0 && this._value >=this.max)){
						this._isElastic=true;
						this._checkElastic=true;
						}else {
						this._isElastic=false;
					}
				}
				}else {
				this._checkElastic=true;
			}
		}
		if (this._isElastic){
			if (this._value <=this.min){
				this.value-=this._lastOffset *Math.max(0,(1-((this.min-this._value)/ this.elasticDistance)));
				}else if (this._value >=this.max){
				this.value-=this._lastOffset *Math.max(0,(1-((this._value-this.max)/ this.elasticDistance)));
			}
			}else {
			this.value-=this._lastOffset;
		}
	}

	/**@private */
	__proto.onStageMouseUp2=function(e){
		Laya.stage.off("mouseup",this,this.onStageMouseUp2);
		Laya.stage.off("mouseout",this,this.onStageMouseUp2);
		Laya.timer.clear(this,this.loop);
		if (this._clickOnly){
			if(this._value>=this.min&&this._value<=this.max)
				return;
		}
		this._target.mouseEnabled=true;
		if (this._isElastic){
			if (this._value < this.min){
				Tween.to(this,{value:this.min},this.elasticBackTime,Ease.sineOut,Handler.create(this,this.elasticOver));
				}else if (this._value > this.max){
				Tween.to(this,{value:this.max},this.elasticBackTime,Ease.sineOut,Handler.create(this,this.elasticOver));
			}
			}else {
			if (!this._offsets)return;
			if (this._offsets.length < 1){
				this._offsets[0]=this.isVertical ? Laya.stage.mouseY-this._lastPoint.y :Laya.stage.mouseX-this._lastPoint.x;
			};
			var offset=0;
			var n=Math.min(this._offsets.length,3);
			for (var i=0;i < n;i++){
				offset+=this._offsets[this._offsets.length-1-i];
			}
			this._lastOffset=offset / n;
			offset=Math.abs(this._lastOffset);
			if (offset < 2){
				this.event("end");
				return;
			}
			if (offset > 60)this._lastOffset=this._lastOffset > 0 ? 60 :-60;
			var dis=Math.round(Math.abs(this.elasticDistance *(this._lastOffset / 240)));
			Laya.timer.frameLoop(1,this,this.tweenMove,[dis]);
		}
	}

	/**@private */
	__proto.elasticOver=function(){
		this._isElastic=false;
		if (!this.hide && this.autoHide){
			Tween.to(this,{alpha:0},500);
		}
		this.event("end");
	}

	/**@private */
	__proto.tweenMove=function(maxDistance){
		this._lastOffset *=this.rollRatio;
		var tarSpeed=NaN;
		if (maxDistance > 0){
			if (this._lastOffset > 0 && this.value <=this.min){
				this._isElastic=true;
				tarSpeed=-(this.min-maxDistance-this.value)*0.5;
				if (this._lastOffset > tarSpeed)this._lastOffset=tarSpeed;
				}else if (this._lastOffset < 0 && this.value >=this.max){
				this._isElastic=true;
				tarSpeed=-(this.max+maxDistance-this.value)*0.5;
				if (this._lastOffset < tarSpeed)this._lastOffset=tarSpeed;
			}
		}
		this.value-=this._lastOffset;
		if (Math.abs(this._lastOffset)< 1){
			Laya.timer.clear(this,this.tweenMove);
			if (this._isElastic){
				if (this._value < this.min){
					Tween.to(this,{value:this.min},this.elasticBackTime,Ease.sineOut,Handler.create(this,this.elasticOver));
					}else if (this._value > this.max){
					Tween.to(this,{value:this.max},this.elasticBackTime,Ease.sineOut,Handler.create(this,this.elasticOver));
					}else {
					this.elasticOver();
				}
				return;
			}
			this.event("end");
			if (!this.hide && this.autoHide){
				Tween.to(this,{alpha:0},500);
			}
		}
	}

	/**
	*停止滑动。
	*/
	__proto.stopScroll=function(){
		this.onStageMouseUp2(null);
		Laya.timer.clear(this,this.tweenMove);
		Tween.clearTween(this);
	}

	/**获取或设置一个值，该值表示滑条长度比例，值为：（0-1）。 */
	__getset(0,__proto,'thumbPercent',function(){
		return this._thumbPercent;
		},function(value){
		this.runCallLater(this.changeScrollBar);
		this.runCallLater(this._sizeChanged);
		value=value >=1 ? 0.99 :value;
		this._thumbPercent=value;
		if (this.scaleBar){
			if (this.slider.isVertical)this.slider.bar.height=Math.max(this.slider.height *value,Styles.scrollBarMinNum);
			else this.slider.bar.width=Math.max(this.slider.width *value,Styles.scrollBarMinNum);
		}
	});

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if ((typeof value=='number')|| (typeof value=='string'))this.value=Number(value);
		else Laya.superSet(UIComponent,this,'dataSource',value);
	});

	/**
	*@copy laya.ui.Image#skin
	*/
	__getset(0,__proto,'skin',function(){
		return this._skin;
		},function(value){
		if (this._skin !=value){
			this._skin=value;
			if (this._skin&&!Loader.getRes(this._skin)){
				Laya.loader.load([this._skin,this._skin.replace(".png","$up.png"),this._skin.replace(".png","$down.png"),this._skin.replace(".png","$bar.png")],Handler.create(this,this._skinLoaded));
				}else{
				this._skinLoaded();
			}
		}
	});

	/**
	*获取或设置表示最高滚动位置的数字。
	*/
	__getset(0,__proto,'max',function(){
		return this.slider.max;
		},function(value){
		this.slider.max=value;
	});

	/**
	*获取或设置表示最低滚动位置的数字。
	*/
	__getset(0,__proto,'min',function(){
		return this.slider.min;
		},function(value){
		this.slider.min=value;
	});

	/**
	*获取或设置表示当前滚动位置的数字。
	*/
	__getset(0,__proto,'value',function(){
		return this._value;
		},function(v){
		if (v!==this._value){
			this._value=v;
			if (!this._isElastic){
				if (this.slider["_value"] !=v){
					this.slider["_value"]=v;
					this.slider.changeValue();
				}
				this._value=this.slider["_value"];
			}
			this.event("change");
			this.changeHandler && this.changeHandler.runWith(this._value);
		}
	});

	/**
	*一个布尔值，指示滚动条是否为垂直滚动。如果值为true，则为垂直滚动，否则为水平滚动。
	*<p>默认值为：true。</p>
	*/
	__getset(0,__proto,'isVertical',function(){
		return this.slider.isVertical;
		},function(value){
		this.slider.isVertical=value;
	});

	/**
	*<p>当前实例的 <code>Slider</code> 实例的有效缩放网格数据。</p>
	*<p>数据格式："上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)"，以逗号分隔。
	*<ul><li>例如："4,4,4,4,1"</li></ul></p>
	*@see laya.ui.AutoBitmap.sizeGrid
	*/
	__getset(0,__proto,'sizeGrid',function(){
		return this.slider.sizeGrid;
		},function(value){
		this.slider.sizeGrid=value;
	});

	/**获取或设置一个值，该值表示按下滚动条轨道时页面滚动的增量。 */
	__getset(0,__proto,'scrollSize',function(){
		return this._scrollSize;
		},function(value){
		this._scrollSize=value;
	});

	/**
	*设置滚动对象。
	*@see laya.ui.TouchScroll#target
	*/
	__getset(0,__proto,'target',function(){
		return this._target;
		},function(value){
		if (this._target){
			this._target.off("mousewheel",this,this.onTargetMouseWheel);
			this._target.off("mousedown",this,this.onTargetMouseDown);
		}
		this._target=value;
		if (value){
			this._mouseWheelEnable && this._target.on("mousewheel",this,this.onTargetMouseWheel);
			this._touchScrollEnable && this._target.on("mousedown",this,this.onTargetMouseDown);
		}
	});

	/**是否隐藏滚动条，不显示滚动条，但是可以正常滚动，默认为false。*/
	__getset(0,__proto,'hide',function(){
		return this._hide;
		},function(value){
		this._hide=value;
		this.visible=!value;
	});

	/**一个布尔值，指定是否显示向上、向下按钮，默认值为true。*/
	__getset(0,__proto,'showButtons',function(){
		return this._showButtons;
		},function(value){
		this._showButtons=value;
		this.callLater(this.changeScrollBar);
	});

	/**一个布尔值，指定是否开启触摸，默认值为true。*/
	__getset(0,__proto,'touchScrollEnable',function(){
		return this._touchScrollEnable;
		},function(value){
		this._touchScrollEnable=value;
		this.target=this._target;
	});

	/**一个布尔值，指定是否滑轮滚动，默认值为true。*/
	__getset(0,__proto,'mouseWheelEnable',function(){
		return this._mouseWheelEnable;
		},function(value){
		this._mouseWheelEnable=value;
		this.target=this._target;
	});

	/**
	*滚动的刻度值，滑动数值为tick的整数倍。默认值为1。
	*/
	__getset(0,__proto,'tick',function(){
		return this.slider.tick;
		},function(value){
		this.slider.tick=value;
	});

	return ScrollBar;
})(UIComponent)


//class laya.ui.Slider extends laya.ui.UIComponent
var Slider=(function(_super){
	function Slider(skin){
		/**
		*数据变化处理器。
		*<p>默认回调参数为滑块位置属性 <code>value</code>属性值：Number 。</p>
		*/
		this.changeHandler=null;
		/**
		*一个布尔值，指示是否为垂直滚动。如果值为true，则为垂直方向，否则为水平方向。
		*<p>默认值为：true。</p>
		*@default true
		*/
		this.isVertical=true;
		/**
		*一个布尔值，指示是否显示标签。
		*@default true
		*/
		this.showLabel=true;
		/**@private */
		this._allowClickBack=false;
		/**@private */
		this._max=100;
		/**@private */
		this._min=0;
		/**@private */
		this._tick=1;
		/**@private */
		this._value=0;
		/**@private */
		this._skin=null;
		/**@private */
		this._bg=null;
		/**@private */
		this._progress=null;
		/**@private */
		this._bar=null;
		/**@private */
		this._tx=NaN;
		/**@private */
		this._ty=NaN;
		/**@private */
		this._maxMove=NaN;
		/**@private */
		this._globalSacle=null;
		Slider.__super.call(this);
		this.skin=skin;
	}

	__class(Slider,'laya.ui.Slider',_super);
	var __proto=Slider.prototype;
	/**
	*@inheritDoc
	*/
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._bg && this._bg.destroy(destroyChild);
		this._bar && this._bar.destroy(destroyChild);
		this._progress && this._progress.destroy(destroyChild);
		this._bg=null;
		this._bar=null;
		this._progress=null;
		this.changeHandler=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this._bg=new Image());
		this.addChild(this._bar=new Button());
	}

	/**@inheritDoc */
	__proto.initialize=function(){
		this._bar.on("mousedown",this,this.onBarMouseDown);
		this._bg.sizeGrid=this._bar.sizeGrid="4,4,4,4,0";
		if (this._progress)this._progress.sizeGrid=this._bar.sizeGrid;
		this.allowClickBack=true;
	}

	/**
	*@private
	*滑块的的 <code>Event.MOUSE_DOWN</code> 事件侦听处理函数。
	*/
	__proto.onBarMouseDown=function(e){
		this._globalSacle || (this._globalSacle=new Point());
		this._globalSacle.setTo(this.globalScaleX || 0.01,this.globalScaleY || 0.01);
		this._maxMove=this.isVertical ? (this.height-this._bar.height):(this.width-this._bar.width);
		this._tx=Laya.stage.mouseX;
		this._ty=Laya.stage.mouseY;
		Laya.stage.on("mousemove",this,this.mouseMove);
		Laya.stage.once("mouseup",this,this.mouseUp);
		Laya.stage.once("mouseout",this,this.mouseUp);
		this.showValueText();
	}

	/**
	*@private
	*显示标签。
	*/
	__proto.showValueText=function(){
		if (this.showLabel){
			var label=laya.ui.Slider.label;
			this.addChild(label);
			label.textField.changeText(this._value+"");
			if (this.isVertical){
				label.x=this._bar._x+20;
				label.y=(this._bar.height-label.height)*0.5+this._bar._y;
				}else {
				label.y=this._bar._y-20;
				label.x=(this._bar.width-label.width)*0.5+this._bar._x;
			}
		}
	}

	/**
	*@private
	*隐藏标签。
	*/
	__proto.hideValueText=function(){
		laya.ui.Slider.label && laya.ui.Slider.label.removeSelf();
	}

	/**
	*@private
	*/
	__proto.mouseUp=function(e){
		Laya.stage.off("mousemove",this,this.mouseMove);
		Laya.stage.off("mouseup",this,this.mouseUp);
		Laya.stage.off("mouseout",this,this.mouseUp);
		this.sendChangeEvent("changed");
		this.hideValueText();
	}

	/**
	*@private
	*/
	__proto.mouseMove=function(e){
		var oldValue=this._value;
		if (this.isVertical){
			this._bar.y+=(Laya.stage.mouseY-this._ty)/ this._globalSacle.y;
			if (this._bar._y > this._maxMove)this._bar.y=this._maxMove;
			else if (this._bar._y < 0)this._bar.y=0;
			this._value=this._bar._y / this._maxMove *(this._max-this._min)+this._min;
			if(this._progress)this._progress.height=this._bar._y+0.5*this._bar.height;
			}else {
			this._bar.x+=(Laya.stage.mouseX-this._tx)/ this._globalSacle.x;
			if (this._bar._x > this._maxMove)this._bar.x=this._maxMove;
			else if (this._bar._x < 0)this._bar.x=0;
			this._value=this._bar._x / this._maxMove *(this._max-this._min)+this._min;
			if(this._progress)this._progress.width=this._bar._x+0.5*this._bar.width;
		}
		this._tx=Laya.stage.mouseX;
		this._ty=Laya.stage.mouseY;
		var pow=Math.pow(10,(this._tick+"").length-1);
		this._value=Math.round(Math.round(this._value / this._tick)*this._tick *pow)/ pow;
		if (this._value !=oldValue){
			this.sendChangeEvent();
		}
		this.showValueText();
	}

	/**
	*@private
	*/
	__proto.sendChangeEvent=function(type){
		(type===void 0)&& (type="change");
		this.event(type);
		this.changeHandler && this.changeHandler.runWith(this._value);
	}

	__proto._skinLoaded=function(){
		this._bg.skin=this._skin;
		this._bar.skin=this._skin.replace(".png","$bar.png");
		var progressSkin=this._skin.replace(".png","$progress.png");
		if (Loader.getRes(progressSkin)){
			if (!this._progress){
				this.addChild(this._progress=new Image());
				this._progress.sizeGrid=this._bar.sizeGrid;
				this.setChildIndex(this._progress,1);
			}
			this._progress.skin=progressSkin;
		}
		this.setBarPoint();
		this.callLater(this.changeValue);
		this.event("loaded");
	}

	/**
	*@private
	*设置滑块的位置信息。
	*/
	__proto.setBarPoint=function(){
		if (this.isVertical)this._bar.x=Math.round((this._bg.width-this._bar.width)*0.5);
		else this._bar.y=Math.round((this._bg.height-this._bar.height)*0.5);
	}

	/**@inheritDoc */
	__proto.measureWidth=function(){
		return Math.max(this._bg.width,this._bar.width);
	}

	/**@inheritDoc */
	__proto.measureHeight=function(){
		return Math.max(this._bg.height,this._bar.height);
	}

	/**@inheritDoc */
	__proto._sizeChanged=function(){
		_super.prototype._sizeChanged.call(this);
		if (this.isVertical)this._bg.height=this.height;
		else this._bg.width=this.width;
		this.setBarPoint();
		this.changeValue();
	}

	/**
	*设置滑动条的信息。
	*@param min 滑块的最小值。
	*@param max 滑块的最小值。
	*@param value 滑块的当前值。
	*/
	__proto.setSlider=function(min,max,value){
		this._value=-1;
		this._min=min;
		this._max=max > min ? max :min;
		this.value=value < min ? min :value > max ? max :value;
	}

	/**
	*@private
	*改变滑块的位置值。
	*/
	__proto.changeValue=function(){
		var pow=Math.pow(10,(this._tick+"").length-1);
		this._value=Math.round(Math.round(this._value / this._tick)*this._tick *pow)/ pow;
		this._value=this._value > this._max ? this._max :this._value < this._min ? this._min :this._value;
		var num=this._max-this._min;
		if (num===0)num=1;
		if (this.isVertical){
			this._bar.y=(this._value-this._min)/ num *(this.height-this._bar.height);
			if(this._progress)this._progress.height=this._bar._y+0.5*this._bar.height;
		}
		else{
			this._bar.x=(this._value-this._min)/ num *(this.width-this._bar.width);
			if(this._progress)this._progress.width=this._bar._x+0.5*this._bar.width;
		}
	}

	/**
	*@private
	*滑动条的 <code>Event.MOUSE_DOWN</code> 事件侦听处理函数。
	*/
	__proto.onBgMouseDown=function(e){
		var point=this._bg.getMousePoint();
		if (this.isVertical)this.value=point.y / (this.height-this._bar.height)*(this._max-this._min)+this._min;
		else this.value=point.x / (this.width-this._bar.width)*(this._max-this._min)+this._min;
	}

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if ((typeof value=='number')|| (typeof value=='string'))this.value=Number(value);
		else Laya.superSet(UIComponent,this,'dataSource',value);
	});

	/**
	*@copy laya.ui.Image#skin
	*/
	__getset(0,__proto,'skin',function(){
		return this._skin;
		},function(value){
		if (this._skin !=value){
			this._skin=value;
			if (this._skin&&!Loader.getRes(this._skin)){
				Laya.loader.load([this._skin,this._skin.replace(".png","$bar.png")],Handler.create(this,this._skinLoaded));
				}else{
				this._skinLoaded();
			}
		}
	});

	/**
	*滑动的刻度值，滑动数值为tick的整数倍。默认值为1。
	*/
	__getset(0,__proto,'tick',function(){
		return this._tick;
		},function(value){
		if (this._tick !=value){
			this._tick=value;
			this.callLater(this.changeValue);
		}
	});

	/**
	*<p>当前实例的背景图（ <code>Image</code> ）和滑块按钮（ <code>Button</code> ）实例的有效缩放网格数据。</p>
	*<p>数据格式："上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)"，以逗号分隔。
	*<ul><li>例如："4,4,4,4,1"</li></ul></p>
	*@see laya.ui.AutoBitmap.sizeGrid
	*/
	__getset(0,__proto,'sizeGrid',function(){
		return this._bg.sizeGrid;
		},function(value){
		this._bg.sizeGrid=value;
		this._bar.sizeGrid=value;
		if (this._progress)this._progress.sizeGrid=this._bar.sizeGrid;
	});

	/**
	*一个布尔值，指定是否允许通过点击滑动条改变 <code>Slider</code> 的 <code>value</code> 属性值。
	*/
	__getset(0,__proto,'allowClickBack',function(){
		return this._allowClickBack;
		},function(value){
		if (this._allowClickBack !=value){
			this._allowClickBack=value;
			if (value)this._bg.on("mousedown",this,this.onBgMouseDown);
			else this._bg.off("mousedown",this,this.onBgMouseDown);
		}
	});

	/**
	*获取或设置表示最高位置的数字。 默认值为100。
	*/
	__getset(0,__proto,'max',function(){
		return this._max;
		},function(value){
		if (this._max !=value){
			this._max=value;
			this.callLater(this.changeValue);
		}
	});

	/**
	*获取或设置表示最低位置的数字。 默认值为0。
	*/
	__getset(0,__proto,'min',function(){
		return this._min;
		},function(value){
		if (this._min !=value){
			this._min=value;
			this.callLater(this.changeValue);
		}
	});

	/**
	*表示滑块按钮的引用。
	*/
	__getset(0,__proto,'bar',function(){
		return this._bar;
	});

	/**
	*获取或设置表示当前滑块位置的数字。
	*/
	__getset(0,__proto,'value',function(){
		return this._value;
		},function(num){
		if (this._value !=num){
			var oldValue=this._value;
			this._value=num;
			this.changeValue();
			if (this._value !=oldValue){
				this.sendChangeEvent();
			}
		}
	});

	__static(Slider,
	['label',function(){return this.label=new Label();}
	]);
	return Slider;
})(UIComponent)


//class laya.ui.Image extends laya.ui.UIComponent
var Image=(function(_super){
	function Image(skin){
		/**@private */
		this._bitmap=null;
		/**@private */
		this._skin=null;
		/**@private */
		this._group=null;
		Image.__super.call(this);
		this.skin=skin;
	}

	__class(Image,'laya.ui.Image',_super);
	var __proto=Image.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,true);
		this._bitmap && this._bitmap.destroy();
		this._bitmap=null;
	}

	/**
	*销毁对象并释放加载的皮肤资源。
	*/
	__proto.dispose=function(){
		this.destroy(true);
		Laya.loader.clearRes(this._skin);
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.graphics=this._bitmap=new AutoBitmap();
		this._bitmap.autoCacheCmd=false;
	}

	/**
	*@private
	*设置皮肤资源。
	*/
	__proto.setSource=function(url,img){
		if (url===this._skin && img){
			this.source=img
			this.onCompResize();
		}
	}

	/**@inheritDoc */
	__proto.measureWidth=function(){
		return this._bitmap.width;
	}

	/**@inheritDoc */
	__proto.measureHeight=function(){
		return this._bitmap.height;
	}

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if ((typeof value=='string'))this.skin=value;
		else Laya.superSet(UIComponent,this,'dataSource',value);
	});

	/**
	*@copy laya.ui.AutoBitmap#source
	*/
	__getset(0,__proto,'source',function(){
		return this._bitmap.source;
		},function(value){
		if (!this._bitmap)return;
		this._bitmap.source=value;
		this.event("loaded");
		this.repaint();
	});

	/**
	*<p>对象的皮肤地址，以字符串表示。</p>
	*<p>如果资源未加载，则先加载资源，加载完成后应用于此对象。</p>
	*<b>注意：</b>资源加载完成后，会自动缓存至资源库中。
	*/
	__getset(0,__proto,'skin',function(){
		return this._skin;
		},function(value){
		if (this._skin !=value){
			this._skin=value;
			if (value){
				var source=Loader.getRes(value);
				if (source){
					this.source=source;
					this.onCompResize();
				}else Laya.loader.load(this._skin,Handler.create(this,this.setSource,[this._skin]),null,"image",1,true,this._group);
				}else {
				this.source=null;
			}
		}
	});

	/**
	*<p>当前实例的位图 <code>AutoImage</code> 实例的有效缩放网格数据。</p>
	*<p>数据格式："上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)"，以逗号分隔。
	*<ul><li>例如："4,4,4,4,1"。</li></ul></p>
	*@see laya.ui.AutoBitmap#sizeGrid
	*/
	__getset(0,__proto,'sizeGrid',function(){
		if (this._bitmap.sizeGrid)return this._bitmap.sizeGrid.join(",");
		return null;
		},function(value){
		this._bitmap.sizeGrid=UIUtils.fillArray(Styles.defaultSizeGrid,value,Number);
	});

	/**
	*资源分组。
	*/
	__getset(0,__proto,'group',function(){
		return this._group;
		},function(value){
		if (value && this._skin)Loader.setGroup(this._skin,value);
		this._group=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(UIComponent,this,'width',value);
		this._bitmap.width=value==0 ? 0.0000001 :value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(UIComponent,this,'height',value);
		this._bitmap.height=value==0 ? 0.0000001 :value;
	});

	return Image;
})(UIComponent)


//class laya.ui.Label extends laya.ui.UIComponent
var Label=(function(_super){
	function Label(text){
		/**
		*@private
		*文本 <code>Text</code> 实例。
		*/
		this._tf=null;
		Label.__super.call(this);
		(text===void 0)&& (text="");
		this.text=text;
	}

	__class(Label,'laya.ui.Label',_super);
	var __proto=Label.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._tf=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this._tf=new Text());
	}

	/**@copy laya.display.Text#changeText()
	**/
	__proto.changeText=function(text){
		this._tf.changeText(text);
	}

	/**
	*@inheritDoc
	*/
	__proto.measureWidth=function(){
		return this._tf.width;
	}

	/**
	*@inheritDoc
	*/
	__proto.measureHeight=function(){
		return this._tf.height;
	}

	/**
	*<p>边距信息</p>
	*<p>"上边距，右边距，下边距 , 左边距（边距以像素为单位）"</p>
	*@see laya.display.Text.padding
	*/
	__getset(0,__proto,'padding',function(){
		return this._tf.padding.join(",");
		},function(value){
		this._tf.padding=UIUtils.fillArray(Styles.labelPadding,value,Number);
	});

	/**
	*@copy laya.display.Text#bold
	*/
	__getset(0,__proto,'bold',function(){
		return this._tf.bold;
		},function(value){
		this._tf.bold=value;
	});

	/**
	*@copy laya.display.Text#align
	*/
	__getset(0,__proto,'align',function(){
		return this._tf.align;
		},function(value){
		this._tf.align=value;
	});

	/**
	*当前文本内容字符串。
	*@see laya.display.Text.text
	*/
	__getset(0,__proto,'text',function(){
		return this._tf.text;
		},function(value){
		if (this._tf.text !=value){
			if(value)
				value=UIUtils.adptString(value+"");
			this._tf.text=value;
			this.event("change");
			if (!this._width || !this._height)this.onCompResize();
		}
	});

	/**
	*@copy laya.display.Text#italic
	*/
	__getset(0,__proto,'italic',function(){
		return this._tf.italic;
		},function(value){
		this._tf.italic=value;
	});

	/**
	*@copy laya.display.Text#wordWrap
	*/
	/**
	*@copy laya.display.Text#wordWrap
	*/
	__getset(0,__proto,'wordWrap',function(){
		return this._tf.wordWrap;
		},function(value){
		this._tf.wordWrap=value;
	});

	/**
	*@copy laya.display.Text#font
	*/
	__getset(0,__proto,'font',function(){
		return this._tf.font;
		},function(value){
		this._tf.font=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if ((typeof value=='number')|| (typeof value=='string'))this.text=value+"";
		else Laya.superSet(UIComponent,this,'dataSource',value);
	});

	/**
	*@copy laya.display.Text#color
	*/
	__getset(0,__proto,'color',function(){
		return this._tf.color;
		},function(value){
		this._tf.color=value;
	});

	/**
	*@copy laya.display.Text#valign
	*/
	__getset(0,__proto,'valign',function(){
		return this._tf.valign;
		},function(value){
		this._tf.valign=value;
	});

	/**
	*@copy laya.display.Text#leading
	*/
	__getset(0,__proto,'leading',function(){
		return this._tf.leading;
		},function(value){
		this._tf.leading=value;
	});

	/**
	*@copy laya.display.Text#fontSize
	*/
	__getset(0,__proto,'fontSize',function(){
		return this._tf.fontSize;
		},function(value){
		this._tf.fontSize=value;
	});

	/**
	*@copy laya.display.Text#bgColor
	*/
	__getset(0,__proto,'bgColor',function(){
		return this._tf.bgColor
		},function(value){
		this._tf.bgColor=value;
	});

	/**
	*@copy laya.display.Text#borderColor
	*/
	__getset(0,__proto,'borderColor',function(){
		return this._tf.borderColor
		},function(value){
		this._tf.borderColor=value;
	});

	/**
	*@copy laya.display.Text#stroke
	*/
	__getset(0,__proto,'stroke',function(){
		return this._tf.stroke;
		},function(value){
		this._tf.stroke=value;
	});

	/**
	*@copy laya.display.Text#strokeColor
	*/
	__getset(0,__proto,'strokeColor',function(){
		return this._tf.strokeColor;
		},function(value){
		this._tf.strokeColor=value;
	});

	/**
	*文本控件实体 <code>Text</code> 实例。
	*/
	__getset(0,__proto,'textField',function(){
		return this._tf;
	});

	/**
	*@inheritDoc
	*/
	/**
	*@inheritDoc
	*/
	__getset(0,__proto,'width',function(){
		if (this._width || this._tf.text)return Laya.superGet(UIComponent,this,'width');
		return 0;
		},function(value){
		Laya.superSet(UIComponent,this,'width',value);
		this._tf.width=value;
	});

	/**
	*@inheritDoc
	*/
	/**
	*@inheritDoc
	*/
	__getset(0,__proto,'height',function(){
		if (this._height || this._tf.text)return Laya.superGet(UIComponent,this,'height');
		return 0;
		},function(value){
		Laya.superSet(UIComponent,this,'height',value);
		this._tf.height=value;
	});

	/**
	*@copy laya.display.Text#overflow
	*/
	/**
	*@copy laya.display.Text#overflow
	*/
	__getset(0,__proto,'overflow',function(){
		return this._tf.overflow;
		},function(value){
		this._tf.overflow=value;
	});

	/**
	*@copy laya.display.Text#underline
	*/
	/**
	*@copy laya.display.Text#underline
	*/
	__getset(0,__proto,'underline',function(){
		return this._tf.underline;
		},function(value){
		this._tf.underline=value;
	});

	/**
	*@copy laya.display.Text#underlineColor
	*/
	/**
	*@copy laya.display.Text#underlineColor
	*/
	__getset(0,__proto,'underlineColor',function(){
		return this._tf.underlineColor;
		},function(value){
		this._tf.underlineColor=value;
	});

	return Label;
})(UIComponent)


//class laya.ui.ProgressBar extends laya.ui.UIComponent
var ProgressBar=(function(_super){
	function ProgressBar(skin){
		/**
		*当 <code>ProgressBar</code> 实例的 <code>value</code> 属性发生变化时的函数处理器。
		*<p>默认返回参数<code>value</code> 属性（进度值）。</p>
		*/
		this.changeHandler=null;
		/**@private */
		this._bg=null;
		/**@private */
		this._bar=null;
		/**@private */
		this._skin=null;
		/**@private */
		this._value=0.5;
		ProgressBar.__super.call(this);
		this.skin=skin;
	}

	__class(ProgressBar,'laya.ui.ProgressBar',_super);
	var __proto=ProgressBar.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._bg && this._bg.destroy(destroyChild);
		this._bar && this._bar.destroy(destroyChild);
		this._bg=this._bar=null;
		this.changeHandler=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this._bg=new Image());
		this.addChild(this._bar=new Image());
		this._bar._bitmap.autoCacheCmd=false;
	}

	__proto._skinLoaded=function(){
		this._bg.skin=this._skin;
		this._bar.skin=this._skin.replace(".png","$bar.png");
		this.callLater(this.changeValue);
		this.event("loaded");
	}

	/**@inheritDoc */
	__proto.measureWidth=function(){
		return this._bg.width;
	}

	/**@inheritDoc */
	__proto.measureHeight=function(){
		return this._bg.height;
	}

	/**
	*@private
	*更改进度值的显示。
	*/
	__proto.changeValue=function(){
		if (this.sizeGrid){
			var grid=this.sizeGrid.split(",");
			var left=Number(grid[3]);
			var right=Number(grid[1]);
			var max=this.width-left-right;
			var sw=max *this._value;
			this._bar.width=left+right+sw;
			this._bar.visible=this._bar.width > left+right;
			}else {
			this._bar.width=this.width *this._value;
		}
	}

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if ((typeof value=='number')|| (typeof value=='string'))this.value=Number(value);
		else Laya.superSet(UIComponent,this,'dataSource',value);
	});

	/**
	*@copy laya.ui.Image#skin
	*/
	__getset(0,__proto,'skin',function(){
		return this._skin;
		},function(value){
		if (this._skin !=value){
			this._skin=value;
			if (this._skin&&!Loader.getRes(this._skin)){
				Laya.loader.load(this._skin,Handler.create(this,this._skinLoaded),null,"image",1);
				}else{
				this._skinLoaded();
			}
		}
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(UIComponent,this,'height',value);
		this._bg.height=this._height;
		this._bar.height=this._height;
	});

	/**
	*获取进度条对象。
	*/
	__getset(0,__proto,'bar',function(){
		return this._bar;
	});

	/**
	*当前的进度量。
	*<p><b>取值：</b>介于0和1之间。</p>
	*/
	__getset(0,__proto,'value',function(){
		return this._value;
		},function(num){
		if (this._value !=num){
			num=num > 1 ? 1 :num < 0 ? 0 :num;
			this._value=num;
			this.callLater(this.changeValue);
			this.event("change");
			this.changeHandler && this.changeHandler.runWith(num);
		}
	});

	/**
	*获取背景条对象。
	*/
	__getset(0,__proto,'bg',function(){
		return this._bg;
	});

	/**
	*<p>当前 <code>ProgressBar</code> 实例的进度条背景位图（ <code>Image</code> 实例）的有效缩放网格数据。</p>
	*<p>数据格式："上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)"，以逗号分隔。
	*<ul><li>例如："4,4,4,4,1"</li></ul></p>
	*@see laya.ui.AutoBitmap.sizeGrid
	*/
	__getset(0,__proto,'sizeGrid',function(){
		return this._bg.sizeGrid;
		},function(value){
		this._bg.sizeGrid=this._bar.sizeGrid=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(UIComponent,this,'width',value);
		this._bg.width=this._width;
		this.callLater(this.changeValue);
	});

	return ProgressBar;
})(UIComponent)


//class laya.utils.GraphicAnimation extends laya.display.FrameAnimation
var GraphicAnimation=(function(_super){
	var GraphicNode;
	function GraphicAnimation(){
		/**@private */
		this.animationList=null;
		/**@private */
		this.animationDic=null;
		/**@private */
		this._nodeList=null;
		/**@private */
		this._nodeDefaultProps=null;
		/**@private */
		this._gList=null;
		/**@private */
		this._nodeIDAniDic={};
		/**@private */
		this._rootNode=null;
		/**@private */
		this._nodeGDic=null;
		GraphicAnimation.__super.call(this);
	}

	__class(GraphicAnimation,'laya.utils.GraphicAnimation',_super);
	var __proto=GraphicAnimation.prototype;
	/**@private */
	__proto._parseNodeList=function(uiView){
		if (!this._nodeList)this._nodeList=[];
		this._nodeDefaultProps[uiView.compId]=uiView.props;
		if (uiView.compId)this._nodeList.push(uiView.compId);
		var childs=uiView.child;
		if (childs){
			var i=0,len=childs.length;
			for (i=0;i < len;i++){
				this._parseNodeList(childs[i]);
			}
		}
	}

	/**@private */
	__proto._calGraphicData=function(aniData){
		this._setUp(null,aniData);
		this._createGraphicData();
	}

	/**@private */
	__proto._createGraphicData=function(){
		var gList=[];
		var i=0,len=this.count;
		var animationDataNew=this._usedFrames;
		if (!animationDataNew)animationDataNew=[];
		var preGraphic;
		for (i=0;i < len;i++){
			if (animationDataNew[i] || !preGraphic){
				preGraphic=this._createFrameGraphic(i);
			}
			gList.push(preGraphic);
		}
		this._gList=gList;
	}

	/**@private */
	__proto._createFrameGraphic=function(frame){
		var g=new Graphics();
		if (!GraphicAnimation._rootMatrix)GraphicAnimation._rootMatrix=new Matrix();
		this._updateNodeGraphic(this._rootNode,frame,GraphicAnimation._rootMatrix,g);
		return g;
	}

	__proto._updateNodeGraphic=function(node,frame,parentTransfrom,g,alpha){
		(alpha===void 0)&& (alpha=1);
		var tNodeG;
		tNodeG=this._nodeGDic[node.compId]=this._getNodeGraphicData(node.compId,frame,this._nodeGDic[node.compId]);
		if (!tNodeG.resultTransform)
			tNodeG.resultTransform=new Matrix();
		var tResultTransform;
		tResultTransform=tNodeG.resultTransform;
		Matrix.mul(tNodeG.transform,parentTransfrom,tResultTransform);
		var tTex;
		var tGraphicAlpha=tNodeG.alpha *alpha;
		if (tGraphicAlpha < 0.01)return;
		if (tNodeG.skin){
			tTex=this._getTextureByUrl(tNodeG.skin);
			if (tTex){
				if (tResultTransform._checkTransform()){
					g.drawTexture(tTex,0,0,tNodeG.width,tNodeG.height,tResultTransform,tGraphicAlpha);
					tNodeG.resultTransform=null;
					}else {
					g.drawTexture(tTex,tResultTransform.tx,tResultTransform.ty,tNodeG.width,tNodeG.height,null,tGraphicAlpha);
				}
			}
		};
		var childs=node.child;
		if (!childs)return;
		var i=0,len=0;
		len=childs.length;
		for (i=0;i < len;i++){
			this._updateNodeGraphic(childs[i],frame,tResultTransform,g,tGraphicAlpha);
		}
	}

	__proto._updateNoChilds=function(tNodeG,g){
		if (!tNodeG.skin)return;
		var tTex=this._getTextureByUrl(tNodeG.skin);
		if (!tTex)return;
		var tTransform=tNodeG.transform;
		tTransform._checkTransform();
		var onlyTranslate=false;
		onlyTranslate=!tTransform._bTransform;
		if (!onlyTranslate){
			g.drawTexture(tTex,0,0,tNodeG.width,tNodeG.height,tTransform.clone(),tNodeG.alpha);
			}else {
			g.drawTexture(tTex,tTransform.tx,tTransform.ty,tNodeG.width,tNodeG.height,null,tNodeG.alpha);
		}
	}

	__proto._updateNodeGraphic2=function(node,frame,g){
		var tNodeG;
		tNodeG=this._nodeGDic[node.compId]=this._getNodeGraphicData(node.compId,frame,this._nodeGDic[node.compId]);
		if (!node.child){
			this._updateNoChilds(tNodeG,g);
			return;
		};
		var tTransform=tNodeG.transform;
		tTransform._checkTransform();
		var onlyTranslate=false;
		onlyTranslate=!tTransform._bTransform;
		var hasTrans=false;
		hasTrans=onlyTranslate && (tTransform.tx !=0 || tTransform.ty !=0);
		var ifSave=false;
		ifSave=(tTransform._bTransform)|| tNodeG.alpha !=1;
		if (ifSave)g.save();
		if (tNodeG.alpha !=1)g.alpha(tNodeG.alpha);
		if (!onlyTranslate)g.transform(tTransform.clone());
		else if (hasTrans)g.translate(tTransform.tx,tTransform.ty);
		var childs=node.child;
		var tTex;
		if (tNodeG.skin){
			tTex=this._getTextureByUrl(tNodeG.skin);
			if (tTex){
				g.drawImage(tTex,0,0,tNodeG.width,tNodeG.height);
			}
		}
		if (childs){
			var i=0,len=0;
			len=childs.length;
			for (i=0;i < len;i++){
				this._updateNodeGraphic2(childs[i],frame,g);
			}
		}
		if (ifSave){
			g.restore();
			}else {
			if (!onlyTranslate){
				g.transform(tTransform.clone().invert());
				}else if (hasTrans){
				g.translate(-tTransform.tx,-tTransform.ty);
			}
		}
	}

	/**@private */
	__proto._calculateKeyFrames=function(node){
		_super.prototype._calculateKeyFrames.call(this,node);
		this._nodeIDAniDic[node.target]=node;
	}

	/**@private */
	__proto.getNodeDataByID=function(nodeID){
		return this._nodeIDAniDic[nodeID];
	}

	/**@private */
	__proto._getParams=function(obj,params,frame,obj2){
		var rst=GraphicAnimation._temParam;
		rst.length=params.length;
		var i=0,len=params.length;
		for (i=0;i < len;i++){
			rst[i]=this._getObjVar(obj,params[i][0],frame,params[i][1],obj2);
		}
		return rst;
	}

	/**@private */
	__proto._getObjVar=function(obj,key,frame,noValue,obj2){
		if (obj.hasOwnProperty(key)){
			var vArr=obj[key];
			if (frame >=vArr.length)frame=vArr.length-1;
			return obj[key][frame];
		}
		if (obj2.hasOwnProperty(key)){
			return obj2[key];
		}
		return noValue;
	}

	__proto._getNodeGraphicData=function(nodeID,frame,rst){
		if (!rst)
			rst=new GraphicNode();
		if (!rst.transform){
			rst.transform=new Matrix();
			}else {
			rst.transform.identity();
		};
		var node=this.getNodeDataByID(nodeID);
		if (!node)return rst;
		var frameData=node.frames;
		var params=this._getParams(frameData,GraphicAnimation._drawTextureCmd,frame,this._nodeDefaultProps[nodeID]);
		var url=params[0];
		var width=NaN,height=NaN;
		var px=params[5],py=params[6];
		var aX=params[13],aY=params[14];
		var sx=params[7],sy=params[8];
		var rotate=params[9];
		var skewX=params[11],skewY=params[12]
		width=params[3];
		height=params[4];
		if (width==0 || height==0)url=null;
		if (width==-1)width=0;
		if (height==-1)height=0;
		var tex;
		rst.skin=url;
		rst.width=width;
		rst.height=height;
		if (url){
			tex=this._getTextureByUrl(url);
			if (tex){
				if (!width)
					width=tex.sourceWidth;
				if (!height)
					height=tex.sourceHeight;
				}else {
				console.warn("lost skin:",url,",you may load pics first");
			}
		}
		rst.alpha=params[10];
		var m=rst.transform;
		if (aX !=0){
			px=aX *width;
		}
		if (aY !=0){
			py=aY *height;
		}
		if (px !=0 || py !=0){
			m.translate(-px,-py);
		};
		var tm=null;
		if (rotate || sx!==1 || sy!==1 || skewX || skewY){
			tm=GraphicAnimation._tempMt;
			tm.identity();
			tm._bTransform=true;
			var skx=(rotate-skewX)*0.0174532922222222;
			var sky=(rotate+skewY)*0.0174532922222222;
			var cx=Math.cos(sky);
			var ssx=Math.sin(sky);
			var cy=Math.sin(skx);
			var ssy=Math.cos(skx);
			tm.a=sx *cx;
			tm.b=sx *ssx;
			tm.c=-sy *cy;
			tm.d=sy *ssy;
			tm.tx=tm.ty=0;
		}
		if (tm){
			m=Matrix.mul(m,tm,m);
		}
		m.translate(params[1],params[2]);
		return rst;
	}

	/**@private */
	__proto._getTextureByUrl=function(url){
		return Loader.getRes(url);
	}

	/**@private */
	__proto.setAniData=function(uiView,aniName){
		if (uiView.animations){
			this._nodeDefaultProps={};
			this._nodeGDic={};
			if (this._nodeList)this._nodeList.length=0;
			this._rootNode=uiView;
			this._parseNodeList(uiView);
			var aniDic={};
			var anilist=[];
			var animations=uiView.animations;
			var i=0,len=animations.length;
			var tAniO;
			for (i=0;i < len;i++){
				tAniO=animations[i];
				this._labels=null;
				if (aniName && aniName !=tAniO.name){
					continue ;
				}
				if (!tAniO)
					continue ;
				try {
					this._calGraphicData(tAniO);
					}catch (e){
					console.warn("parse animation fail:"+tAniO.name+",empty animation created");
					this._gList=[];
				};
				var frameO={};
				frameO.interval=1000 / tAniO["frameRate"];
				frameO.frames=this._gList;
				frameO.labels=this._labels;
				frameO.name=tAniO.name;
				anilist.push(frameO);
				aniDic[tAniO.name]=frameO;
			}
			this.animationList=anilist;
			this.animationDic=aniDic;
		}
		GraphicAnimation._temParam.length=0;
	}

	__proto.parseByData=function(aniData){
		var rootNode,aniO;
		rootNode=aniData.nodeRoot;
		aniO=aniData.aniO;
		delete aniData.nodeRoot;
		delete aniData.aniO;
		this._nodeDefaultProps={};
		this._nodeGDic={};
		if (this._nodeList)this._nodeList.length=0;
		this._rootNode=rootNode;
		this._parseNodeList(rootNode);
		this._labels=null;
		try {
			this._calGraphicData(aniO);
			}catch (e){
			console.warn("parse animation fail:"+aniO.name+",empty animation created");
			this._gList=[];
		};
		var frameO=aniData;
		frameO.interval=1000 / aniO["frameRate"];
		frameO.frames=this._gList;
		frameO.labels=this._labels;
		frameO.name=aniO.name;
		return frameO;
	}

	/**@private */
	__proto.setUpAniData=function(uiView){
		if (uiView.animations){
			var aniDic={};
			var anilist=[];
			var animations=uiView.animations;
			var i=0,len=animations.length;
			var tAniO;
			for (i=0;i < len;i++){
				tAniO=animations[i];
				if (!tAniO)continue ;
				var frameO={};
				frameO.name=tAniO.name;
				frameO.aniO=tAniO;
				frameO.nodeRoot=uiView;
				anilist.push(frameO);
				aniDic[tAniO.name]=frameO;
			}
			this.animationList=anilist;
			this.animationDic=aniDic;
		}
	}

	/**@private */
	__proto._clear=function(){
		this.animationList=null;
		this.animationDic=null;
		this._gList=null;
		this._nodeGDic=null;
	}

	GraphicAnimation.parseAnimationByData=function(animationObject){
		if (!GraphicAnimation._I)GraphicAnimation._I=new GraphicAnimation();
		var rst;
		rst=GraphicAnimation._I.parseByData(animationObject);
		GraphicAnimation._I._clear();
		return rst;
	}

	GraphicAnimation.parseAnimationData=function(aniData){
		if (!GraphicAnimation._I)GraphicAnimation._I=new GraphicAnimation();
		GraphicAnimation._I.setUpAniData(aniData);
		var rst;
		rst={};
		rst.animationList=GraphicAnimation._I.animationList;
		rst.animationDic=GraphicAnimation._I.animationDic;
		GraphicAnimation._I._clear();
		return rst;
	}

	GraphicAnimation._temParam=[];
	GraphicAnimation._I=null;
	GraphicAnimation._rootMatrix=null;
	__static(GraphicAnimation,
	['_drawTextureCmd',function(){return this._drawTextureCmd=[["skin",null],["x",0],["y",0],["width",-1],["height",-1],["pivotX",0],["pivotY",0],["scaleX",1],["scaleY",1],["rotation",0],["alpha",1],["skewX",0],["skewY",0],["anchorX",0],["anchorY",0]];},'_tempMt',function(){return this._tempMt=new Matrix();}
	]);
	GraphicAnimation.__init$=function(){
		//class GraphicNode
		GraphicNode=(function(){
			function GraphicNode(){
				this.skin=null;
				this.transform=null;
				this.resultTransform=null;
				this.width=NaN;
				this.height=NaN;
				this.alpha=1;
			}
			__class(GraphicNode,'');
			return GraphicNode;
		})()
	}

	return GraphicAnimation;
})(FrameAnimation)


//class laya.ui.Dialog extends laya.ui.View
var Dialog=(function(_super){
	function Dialog(){
		/**
		*对话框被关闭时会触发的回调函数处理器。
		*<p>回调函数参数为用户点击的按钮名字name:String。</p>
		*/
		this.closeHandler=null;
		/**
		*弹出对话框效果，可以设置一个效果代替默认的弹出效果，如果不想有任何效果，可以赋值为null
		*全局默认弹出效果可以通过manager.popupEffect修改
		*/
		this.popupEffect=null;
		/**
		*关闭对话框效果，可以设置一个效果代替默认的关闭效果，如果不想有任何效果，可以赋值为null
		*全局默认关闭效果可以通过manager.closeEffect修改
		*/
		this.closeEffect=null;
		/**组名称*/
		this.group=null;
		/**是否是模式窗口*/
		this.isModal=false;
		/**是否显示弹出效果*/
		this.isShowEffect=true;
		/**指定对话框是否居中弹。<p>如果值为true，则居中弹出，否则，则根据对象坐标显示，默认为true。</p>*/
		this.isPopupCenter=true;
		/**关闭类型，点击name为"close"，"cancel"，"sure"，"no"，"yes"，"no"的按钮时，会自动记录点击按钮的名称*/
		this.closeType=null;
		/**@private */
		this._dragArea=null;
		Dialog.__super.call(this);
		this.popupEffect=Dialog.manager.popupEffectHandler;
		this.closeEffect=Dialog.manager.closeEffectHandler;
		this._dealDragArea();
		this.on("click",this,this._onClick);
	}

	__class(Dialog,'laya.ui.Dialog',_super);
	var __proto=Dialog.prototype;
	/**@private 提取拖拽区域*/
	__proto._dealDragArea=function(){
		var dragTarget=this.getChildByName("drag");
		if (dragTarget){
			this.dragArea=dragTarget._x+","+dragTarget._y+","+dragTarget.width+","+dragTarget.height;
			dragTarget.removeSelf();
		}
	}

	/**@private */
	__proto._onMouseDown=function(e){
		var point=this.getMousePoint();
		if (this._dragArea.contains(point.x,point.y))this.startDrag();
		else this.stopDrag();
	}

	/**@private 处理默认点击事件*/
	__proto._onClick=function(e){
		var btn=e.target;
		if (btn){
			switch (btn.name){
				case "close":
				case "cancel":
				case "sure":
				case "no":
				case "ok":
				case "yes":
					this.closeType=btn.name;
					this.close();
					return;
				}
		}
		this.closeType=null;
	}

	/**@inheritDoc */
	__proto.open=function(closeOther){
		(closeOther===void 0)&& (closeOther=true);
		this._dealDragArea();
		Dialog.manager.open(this,closeOther,this.isShowEffect);
		Dialog.manager.lock(false);
	}

	/**
	*关闭对话框。
	*/
	__proto.close=function(){
		Dialog.manager.close(this);
	}

	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		this.closeHandler=null;
		this.popupEffect=null;
		this.closeEffect=null;
		this._dragArea=null;
		_super.prototype.destroy.call(this,destroyChild);
	}

	/**
	*显示对话框（以非模式窗口方式显示）。
	*@param closeOther 是否关闭其它的对话框。若值为true则关闭其它对话框。
	*@param showEffect 是否显示弹出效果
	*/
	__proto.show=function(closeOther,showEffect){
		(closeOther===void 0)&& (closeOther=false);
		(showEffect===void 0)&& (showEffect=true);
		this._open(false,closeOther,showEffect);
	}

	/**
	*显示对话框（以模式窗口方式显示）。
	*@param closeOther 是否关闭其它的对话框。若值为true则关闭其它对话框。
	*@param showEffect 是否显示弹出效果
	*/
	__proto.popup=function(closeOther,showEffect){
		(closeOther===void 0)&& (closeOther=false);
		(showEffect===void 0)&& (showEffect=true);
		this._open(true,closeOther,showEffect);
	}

	/**@private */
	__proto._open=function(modal,closeOther,showEffect){
		this.isModal=modal;
		this.isShowEffect=showEffect;
		Dialog.manager.lock(true);
		this.open(closeOther);
	}

	/**
	*用来指定对话框的拖拽区域。默认值为"0,0,0,0"。
	*<p><b>格式：</b>构成一个矩形所需的 x,y,width,heith 值，用逗号连接为字符串。
	*例如："0,0,100,200"。</p>
	*@see #includeExamplesSummary 请参考示例
	*/
	__getset(0,__proto,'dragArea',function(){
		if (this._dragArea)return this._dragArea.toString();
		return null;
		},function(value){
		if (value){
			var a=UIUtils.fillArray([0,0,0,0],value,Number);
			this._dragArea=new Rectangle(a[0],a[1],a[2],a[3]);
			this.on("mousedown",this,this._onMouseDown);
			}else {
			this._dragArea=null;
			this.off("mousedown",this,this._onMouseDown);
		}
	});

	/**弹出框的显示状态；如果弹框处于显示中，则为true，否则为false;*/
	__getset(0,__proto,'isPopup',function(){
		return this.parent !=null;
	});

	/**@inheritDoc */
	__getset(0,__proto,'zOrder',_super.prototype._$get_zOrder,function(value){
		Laya.superSet(View,this,'zOrder',value);
		Dialog.manager._checkMask();
	});

	/**对话框管理容器，所有的对话框都在该容器内，并且受管理器管理，可以自定义自己的管理器，来更改窗口管理的流程。
	*任意对话框打开和关闭，都会触发管理类的open和close事件*/
	__getset(1,Dialog,'manager',function(){
		return Dialog._manager=Dialog._manager|| new DialogManager();
		},function(value){
		Dialog._manager=value;
	});

	Dialog.setLockView=function(view){
		Dialog.manager.setLockView(view);
	}

	Dialog.lock=function(value){
		Dialog.manager.lock(value);
	}

	Dialog.closeAll=function(){
		Dialog.manager.closeAll();
	}

	Dialog.getDialogsByGroup=function(group){
		return Dialog.manager.getDialogsByGroup(group);
	}

	Dialog.closeByGroup=function(group){
		return Dialog.manager.closeByGroup(group);
	}

	Dialog.CLOSE="close";
	Dialog.CANCEL="cancel";
	Dialog.SURE="sure";
	Dialog.NO="no";
	Dialog.YES="yes";
	Dialog.OK="ok";
	Dialog._manager=null;
	return Dialog;
})(View)


//class laya.ui.CheckBox extends laya.ui.Button
var CheckBox=(function(_super){
	/**
	*创建一个新的 <code>CheckBox</code> 组件实例。
	*@param skin 皮肤资源地址。
	*@param label 文本标签的内容。
	*/
	function CheckBox(skin,label){
		(label===void 0)&& (label="");
		CheckBox.__super.call(this,skin,label);
	}

	__class(CheckBox,'laya.ui.CheckBox',_super);
	var __proto=CheckBox.prototype;
	/**@inheritDoc */
	__proto.preinitialize=function(){
		laya.ui.UIComponent.prototype.preinitialize.call(this);
		this.toggle=true;
		this._autoSize=false;
	}

	/**@inheritDoc */
	__proto.initialize=function(){
		_super.prototype.initialize.call(this);
		this.createText();
		this._text.align="left";
		this._text.valign="top";
		this._text.width=0;
	}

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if ((typeof value=='boolean'))this.selected=value;
		else if ((typeof value=='string'))this.selected=value==="true";
		else Laya.superSet(Button,this,'dataSource',value);
	});

	return CheckBox;
})(Button)


//class laya.ui.LayoutBox extends laya.ui.Box
var LayoutBox=(function(_super){
	function LayoutBox(){
		/**@private */
		this._space=0;
		/**@private */
		this._align="none";
		/**@private */
		this._itemChanged=false;
		LayoutBox.__super.call(this);
	}

	__class(LayoutBox,'laya.ui.LayoutBox',_super);
	var __proto=LayoutBox.prototype;
	/**@inheritDoc */
	__proto.addChild=function(child){
		child.on("resize",this,this.onResize);
		this._setItemChanged();
		return laya.display.Node.prototype.addChild.call(this,child);
	}

	__proto.onResize=function(e){
		this._setItemChanged();
	}

	/**@inheritDoc */
	__proto.addChildAt=function(child,index){
		child.on("resize",this,this.onResize);
		this._setItemChanged();
		return laya.display.Node.prototype.addChildAt.call(this,child,index);
	}

	/**@inheritDoc */
	__proto.removeChildAt=function(index){
		this.getChildAt(index).off("resize",this,this.onResize);
		this._setItemChanged();
		return laya.display.Node.prototype.removeChildAt.call(this,index);
	}

	/**刷新。*/
	__proto.refresh=function(){
		this._setItemChanged();
	}

	/**
	*改变子对象的布局。
	*/
	__proto.changeItems=function(){
		this._itemChanged=false;
	}

	/**
	*排序项目列表。可通过重写改变默认排序规则。
	*@param items 项目列表。
	*/
	__proto.sortItem=function(items){
		if (items)items.sort(function(a,b){return a.y-b.y;});
	}

	__proto._setItemChanged=function(){
		if (!this._itemChanged){
			this._itemChanged=true;
			this.callLater(this.changeItems);
		}
	}

	/**子对象的间隔。*/
	__getset(0,__proto,'space',function(){
		return this._space;
		},function(value){
		this._space=value;
		this._setItemChanged();
	});

	/**子对象对齐方式。*/
	__getset(0,__proto,'align',function(){
		return this._align;
		},function(value){
		this._align=value;
		this._setItemChanged();
	});

	return LayoutBox;
})(Box)


//class laya.ui.FontClip extends laya.ui.Clip
var FontClip=(function(_super){
	function FontClip(skin,sheet){
		/**数值*/
		this._valueArr=null;
		/**文字内容数组**/
		this._indexMap=null;
		/**位图字体内容**/
		this._sheet=null;
		/**@private */
		this._direction="horizontal";
		/**X方向间隙*/
		this._spaceX=0;
		/**Y方向间隙*/
		this._spaceY=0;
		/**@private 水平对齐方式*/
		this._align="left";
		/**@private 显示文字宽*/
		this._wordsW=0;
		/**@private 显示文字高*/
		this._wordsH=0;
		FontClip.__super.call(this);
		if (skin)this.skin=skin;
		if (sheet)this.sheet=sheet;
	}

	__class(FontClip,'laya.ui.FontClip',_super);
	var __proto=FontClip.prototype;
	__proto.createChildren=function(){
		this._bitmap=new AutoBitmap();
		this.on("loaded",this,this._onClipLoaded);
	}

	/**
	*资源加载完毕
	*/
	__proto._onClipLoaded=function(){
		this.callLater(this.changeValue);
	}

	/**渲染数值*/
	__proto.changeValue=function(){
		if (!this._sources)return;
		if (!this._valueArr)return;
		this.graphics.clear(true);
		var texture;
		texture=this._sources[0];
		if (!texture)return;
		var isHorizontal=(this._direction==="horizontal");
		if (isHorizontal){
			this._wordsW=this._valueArr.length *(texture.sourceWidth+this.spaceX);
			this._wordsH=texture.sourceHeight;
			}else{
			this._wordsW=texture.sourceWidth;
			this._wordsH=(texture.sourceHeight+this.spaceY)*this._valueArr.length;
		};
		var dX=0;
		if (this._width){
			switch(this._align){
				case "center":
					dX=0.5 *(this._width-this._wordsW);
					break ;
				case "right":
					dX=this._width-this._wordsW;
					break ;
				default :
					dX=0;
				}
		}
		for (var i=0,sz=this._valueArr.length;i < sz;i++){
			var index=this._indexMap[this._valueArr.charAt(i)];
			if (!this.sources[index])continue ;
			texture=this.sources[index];
			if (isHorizontal)this.graphics.drawImage(texture,dX+i *(texture.sourceWidth+this.spaceX),0,texture.sourceWidth,texture.sourceHeight);
			else this.graphics.drawImage(texture,0+dX,i *(texture.sourceHeight+this.spaceY),texture.sourceWidth,texture.sourceHeight);
		}
		if (!this._width){
			this._widget.resetLayoutX();
			this.callLater(this._sizeChanged);
		}
		if (!this._height){
			this._widget.resetLayoutY();
			this.callLater(this._sizeChanged);
		}
	}

	__proto.measureWidth=function(){
		return this._wordsW;
	}

	__proto.measureHeight=function(){
		return this._wordsH;
	}

	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		this._valueArr=null;
		this._indexMap=null;
		this.graphics.clear(true);
		this.removeSelf();
		this.off("loaded",this,this._onClipLoaded);
		_super.prototype.destroy.call(this,destroyChild);
	}

	/**
	*设置位图字体内容，空格代表换行。比如"abc123 456"，代表第一行对应的文字为"abc123"，第二行为"456"
	*/
	__getset(0,__proto,'sheet',function(){
		return this._sheet;
		},function(value){
		value+="";
		this._sheet=value;
		var arr=value.split(" ");
		this._clipX=String(arr[0]).length;
		this.clipY=arr.length;
		this._indexMap={};
		for (var i=0;i < this._clipY;i++){
			var line=arr[i].split("");
			for (var j=0,n=line.length;j < n;j++){
				this._indexMap[line[j]]=i *this._clipX+j;
			}
		}
	});

	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(Clip,this,'height',value);
		this.callLater(this.changeValue);
	});

	/**
	*布局方向。
	*<p>默认值为"horizontal"。</p>
	*<p><b>取值：</b>
	*<li>"horizontal"：表示水平布局。</li>
	*<li>"vertical"：表示垂直布局。</li>
	*</p>
	*/
	__getset(0,__proto,'direction',function(){
		return this._direction;
		},function(value){
		this._direction=value;
		this.callLater(this.changeValue);
	});

	/**
	*设置位图字体的显示内容
	*/
	__getset(0,__proto,'value',function(){
		if (!this._valueArr)return "";
		return this._valueArr;
		},function(value){
		value+="";
		this._valueArr=value;
		this.callLater(this.changeValue);
	});

	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(Clip,this,'width',value);
		this.callLater(this.changeValue);
	});

	/**X方向文字间隙*/
	__getset(0,__proto,'spaceX',function(){
		return this._spaceX;
		},function(value){
		this._spaceX=value;
		if (this._direction==="horizontal")this.callLater(this.changeValue);
	});

	/**Y方向文字间隙*/
	__getset(0,__proto,'spaceY',function(){
		return this._spaceY;
		},function(value){
		this._spaceY=value;
		if (!(this._direction==="horizontal"))this.callLater(this.changeValue);
	});

	/**水平对齐方式*/
	__getset(0,__proto,'align',function(){
		return this._align;
		},function(v){
		this._align=v;
		this.callLater(this.changeValue);
	});

	return FontClip;
})(Clip)


//class laya.ui.List extends laya.ui.Box
var List=(function(_super){
	function List(){
		/**改变 <code>List</code> 的选择项时执行的处理器，(默认返回参数： 项索引（index:int）)。*/
		this.selectHandler=null;
		/**单元格渲染处理器(默认返回参数cell:Box,index:int)。*/
		this.renderHandler=null;
		/**单元格鼠标事件处理器(默认返回参数e:Event,index:int)。*/
		this.mouseHandler=null;
		/**指定是否可以选择，若值为true则可以选择，否则不可以选择。 @default false*/
		this.selectEnable=false;
		/**最大分页数。*/
		this.totalPage=0;
		/**@private */
		this._$componentType="List";
		/**@private */
		this._content=null;
		/**@private */
		this._scrollBar=null;
		/**@private */
		this._itemRender=null;
		/**@private */
		this._repeatX=0;
		/**@private */
		this._repeatY=0;
		/**@private */
		this._repeatX2=0;
		/**@private */
		this._repeatY2=0;
		/**@private */
		this._spaceX=0;
		/**@private */
		this._spaceY=0;
		/**@private */
		this._array=null;
		/**@private */
		this._startIndex=0;
		/**@private */
		this._selectedIndex=-1;
		/**@private */
		this._page=0;
		/**@private */
		this._isVertical=true;
		/**@private */
		this._cellSize=20;
		/**@private */
		this._cellOffset=0;
		/**@private */
		this._isMoved=false;
		/**是否缓存内容，如果数据源较少，并且list内无动画，设置此属性为true能大大提高性能 */
		this.cacheContent=false;
		/**@private */
		this._createdLine=0;
		/**@private */
		this._cellChanged=false;
		/**@private */
		this._usedCache=null;
		List.__super.call(this);
		this._cells=[];
		this._offset=new Point();
	}

	__class(List,'laya.ui.List',_super);
	var __proto=List.prototype;
	Laya.imps(__proto,{"laya.ui.IRender":true,"laya.ui.IItem":true})
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		this._content && this._content.destroy(destroyChild);
		this._scrollBar && this._scrollBar.destroy(destroyChild);
		laya.ui.UIComponent.prototype.destroy.call(this,destroyChild);
		this._content=null;
		this._scrollBar=null;
		this._itemRender=null;
		this._cells=null;
		this._array=null;
		this.selectHandler=this.renderHandler=this.mouseHandler=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this._content=new Box());
	}

	__proto.onScrollStart=function(){
		this._usedCache || (this._usedCache=Laya.superGet(Box,this,'cacheAs'));
		Laya.superSet(Box,this,'cacheAs',"none");
		this._scrollBar.once("end",this,this.onScrollEnd);
	}

	__proto.onScrollEnd=function(){
		Laya.superSet(Box,this,'cacheAs',this._usedCache);
	}

	__proto._removePreScrollBar=function(){
		var preNode=this.removeChildByName("scrollBar");
		if (preNode)preNode.destroy(true);
	}

	/**
	*@private
	*更改单元格的信息。
	*@internal 在此销毁、创建单元格，并设置单元格的位置等属性。相当于此列表内容发送改变时调用此函数。
	*/
	__proto.changeCells=function(){
		this._cellChanged=false;
		if (this._itemRender){
			this.scrollBar=this.getChildByName("scrollBar");
			var cell=this._getOneCell();
			var cellWidth=(cell.width+this._spaceX)|| 1;
			var cellHeight=(cell.height+this._spaceY)|| 1;
			if (this._width > 0)this._repeatX2=this._isVertical ? Math.round(this._width / cellWidth):Math.ceil(this._width / cellWidth);
			if (this._height > 0)this._repeatY2=this._isVertical ? Math.ceil(this._height / cellHeight):Math.round(this._height / cellHeight);
			var listWidth=this._width ? this._width :(cellWidth *this.repeatX-this._spaceX);
			var listHeight=this._height ? this._height :(cellHeight *this.repeatY-this._spaceY);
			this._cellSize=this._isVertical ? cellHeight :cellWidth;
			this._cellOffset=this._isVertical ? (cellHeight *Math.max(this._repeatY2,this._repeatY)-listHeight-this._spaceY):(cellWidth *Math.max(this._repeatX2,this._repeatX)-listWidth-this._spaceX);
			if (this._isVertical && this.vScrollBarSkin)this._scrollBar.height=listHeight;
			else if (!this._isVertical && this.hScrollBarSkin)this._scrollBar.width=listWidth;
			this.setContentSize(listWidth,listHeight);
			var numX=this._isVertical ? this.repeatX :this.repeatY;
			var numY=(this._isVertical ? this.repeatY :this.repeatX)+(this._scrollBar ? 1 :0);
			this._createItems(0,numX,numY);
			this._createdLine=numY;
			if (this._array){
				this.array=this._array;
				this.runCallLater(this.renderItems);
			}
		}
	}

	__proto._getOneCell=function(){
		if (this._cells.length===0){
			var item=this.createItem();
			this._offset.setTo(item._x,item._y);
			if (this.cacheContent)return item;
			this._cells.push(item);
		}
		return this._cells[0];
	}

	__proto._createItems=function(startY,numX,numY){
		var box=this._content;
		var cell=this._getOneCell();
		var cellWidth=cell.width+this._spaceX;
		var cellHeight=cell.height+this._spaceY;
		if (this.cacheContent){
			var cacheBox=new Box();
			cacheBox.cacheAs="normal";
			cacheBox.pos((this._isVertical ? 0 :startY)*cellWidth,(this._isVertical ? startY :0)*cellHeight);
			this._content.addChild(cacheBox);
			box=cacheBox;
			}else {
			var arr=[];
			for (var i=this._cells.length-1;i >-1;i--){
				var item=this._cells[i];
				item.removeSelf();
				arr.push(item);
			}
			this._cells.length=0;
		}
		for (var k=startY;k < numY;k++){
			for (var l=0;l < numX;l++){
				if (arr && arr.length){
					cell=arr.pop();
					}else {
					cell=this.createItem();
				}
				cell.x=(this._isVertical ? l :k)*cellWidth-box._x;
				cell.y=(this._isVertical ? k :l)*cellHeight-box._y;
				cell.name="item"+(k *numX+l);
				box.addChild(cell);
				this.addCell(cell);
			}
		}
	}

	__proto.createItem=function(){
		var arr=[];
		if ((typeof this._itemRender=='function')){
			var box=new this._itemRender();
			}else {
			box=SceneUtils.createComp(this._itemRender,null,null,arr)
		}
		if (arr.length==0 && box["_watchMap"]){
			var watchMap=box["_watchMap"];
			for (var name in watchMap){
				var a=watchMap[name];
				for (var i=0;i < a.length;i++){
					var watcher=a[i];
					arr.push(watcher.comp,watcher.prop,watcher.value)
				}
			}
		}
		if (arr.length)box["_$bindData"]=arr;
		return box;
	}

	/**
	*@private
	*添加单元格。
	*@param cell 需要添加的单元格对象。
	*/
	__proto.addCell=function(cell){
		cell.on("click",this,this.onCellMouse);
		cell.on("rightclick",this,this.onCellMouse);
		cell.on("mouseover",this,this.onCellMouse);
		cell.on("mouseout",this,this.onCellMouse);
		cell.on("mousedown",this,this.onCellMouse);
		cell.on("mouseup",this,this.onCellMouse);
		this._cells.push(cell);
	}

	__proto._afterInited=function(){
		this.initItems();
	}

	/**
	*初始化单元格信息。
	*/
	__proto.initItems=function(){
		if (!this._itemRender && this.getChildByName("item0")!=null){
			this.repeatX=1;
			var count=0;
			count=0;
			for (var i=0;i < 10000;i++){
				var cell=this.getChildByName("item"+i);
				if (cell){
					this.addCell(cell);
					count++;
					continue ;
				}
				break ;
			}
			this.repeatY=count;
		}
	}

	/**
	*设置可视区域大小。
	*<p>以（0，0，width参数，height参数）组成的矩形区域为可视区域。</p>
	*@param width 可视区域宽度。
	*@param height 可视区域高度。
	*/
	__proto.setContentSize=function(width,height){
		this._content.width=width;
		this._content.height=height;
		if (this._scrollBar||this._offset.x!=0||this._offset.y!=0){
			this._content._style.scrollRect || (this._content.scrollRect=Rectangle.create());
			this._content._style.scrollRect.setTo(-this._offset.x,-this._offset.y,width,height);
			this._content.scrollRect=this._content.scrollRect;
		}
		this.event("resize");
	}

	/**
	*@private
	*单元格的鼠标事件侦听处理函数。
	*/
	__proto.onCellMouse=function(e){
		if (e.type==="mousedown")this._isMoved=false;
		var cell=e.currentTarget;
		var index=this._startIndex+this._cells.indexOf(cell);
		if (index < 0)return;
		if (e.type==="click" || e.type==="rightclick"){
			if (this.selectEnable && !this._isMoved)this.selectedIndex=index;
			else this.changeCellState(cell,true,0);
			}else if ((e.type==="mouseover" || e.type==="mouseout")&& this._selectedIndex!==index){
			this.changeCellState(cell,e.type==="mouseover",0);
		}
		this.mouseHandler && this.mouseHandler.runWith([e,index]);
	}

	/**
	*@private
	*改变单元格的可视状态。
	*@param cell 单元格对象。
	*@param visable 是否显示。
	*@param index 单元格的属性 <code>index</code> 值。
	*/
	__proto.changeCellState=function(cell,visible,index){
		var selectBox=cell.getChildByName("selectBox");
		if (selectBox){
			this.selectEnable=true;
			selectBox.visible=visible;
			selectBox.index=index;
		}
	}

	/**@inheritDoc */
	__proto._sizeChanged=function(){
		laya.ui.UIComponent.prototype._sizeChanged.call(this);
		this.setContentSize(this.width,this.height);
		if (this._scrollBar)this.callLater(this.onScrollBarChange);
	}

	/**
	*@private
	*滚动条的 <code>Event.CHANGE</code> 事件侦听处理函数。
	*/
	__proto.onScrollBarChange=function(e){
		this.runCallLater(this.changeCells);
		var scrollValue=this._scrollBar.value;
		var lineX=(this._isVertical ? this.repeatX :this.repeatY);
		var lineY=(this._isVertical ? this.repeatY :this.repeatX);
		var scrollLine=Math.floor(scrollValue / this._cellSize);
		if (!this.cacheContent){
			var index=scrollLine *lineX;
			var num=0;
			if (index > this._startIndex){
				num=index-this._startIndex;
				var down=true;
				var toIndex=this._startIndex+lineX *(lineY+1);
				this._isMoved=true;
				}else if (index < this._startIndex){
				num=this._startIndex-index;
				down=false;
				toIndex=this._startIndex-1;
				this._isMoved=true;
			}
			for (var i=0;i < num;i++){
				if (down){
					var cell=this._cells.shift();
					this._cells[this._cells.length]=cell;
					var cellIndex=toIndex+i;
					}else {
					cell=this._cells.pop();
					this._cells.unshift(cell);
					cellIndex=toIndex-i;
				};
				var pos=Math.floor(cellIndex / lineX)*this._cellSize;
				this._isVertical ? cell.y=pos :cell.x=pos;
				this.renderItem(cell,cellIndex);
			}
			this._startIndex=index;
			this.changeSelectStatus();
			}else {
			num=(lineY+1);
			if (this._createdLine-scrollLine < num){
				this._createItems(this._createdLine,lineX,this._createdLine+num);
				this.renderItems(this._createdLine *lineX,0);
				this._createdLine+=num;
			}
		};
		var r=this._content._style.scrollRect;
		if (this._isVertical){
			r.y=scrollValue-this._offset.y;
			r.x=-this._offset.x;
			}else {
			r.y=-this._offset.y;
			r.x=scrollValue-this._offset.x;
		}
		this._content.scrollRect=r;
	}

	__proto.posCell=function(cell,cellIndex){
		if (!this._scrollBar)return;
		var lineX=(this._isVertical ? this.repeatX :this.repeatY);
		var lineY=(this._isVertical ? this.repeatY :this.repeatX);
		var pos=Math.floor(cellIndex / lineX)*this._cellSize;
		this._isVertical ? cell._y=pos :cell.x=pos;
	}

	/**
	*@private
	*改变单元格的选择状态。
	*/
	__proto.changeSelectStatus=function(){
		for (var i=0,n=this._cells.length;i < n;i++){
			this.changeCellState(this._cells[i],this._selectedIndex===this._startIndex+i,1);
		}
	}

	/**
	*@private
	*渲染单元格列表。
	*/
	__proto.renderItems=function(from,to){
		(from===void 0)&& (from=0);
		(to===void 0)&& (to=0);
		for (var i=from,n=to || this._cells.length;i < n;i++){
			this.renderItem(this._cells[i],this._startIndex+i);
		}
		this.changeSelectStatus();
	}

	/**
	*渲染一个单元格。
	*@param cell 需要渲染的单元格对象。
	*@param index 单元格索引。
	*/
	__proto.renderItem=function(cell,index){
		if (this._array && index >=0 && index < this._array.length){
			cell.visible=true;
			if (cell["_$bindData"]){
				cell["_dataSource"]=this._array[index];
				this._bindData(cell,this._array[index]);
			}else cell.dataSource=this._array[index];
			if (!this.cacheContent){
				this.posCell(cell,index);
			}
			if (this.hasListener("render"))this.event("render",[cell,index]);
			if (this.renderHandler)this.renderHandler.runWith([cell,index]);
			}else {
			cell.visible=false;
			cell.dataSource=null;
		}
	}

	__proto._bindData=function(cell,data){
		var arr=cell._$bindData;
		for (var i=0,n=arr.length;i < n;i++){
			var ele=arr[i++];
			var prop=arr[i++];
			var value=arr[i];
			var fun=UIUtils.getBindFun(value);
			ele[prop]=fun.call(this,data);
		}
	}

	/**
	*刷新列表数据源。
	*/
	__proto.refresh=function(){
		this.array=this._array;
	}

	/**
	*获取单元格数据源。
	*@param index 单元格索引。
	*/
	__proto.getItem=function(index){
		if (index >-1 && index < this._array.length){
			return this._array[index];
		}
		return null;
	}

	/**
	*修改单元格数据源。
	*@param index 单元格索引。
	*@param source 单元格数据源。
	*/
	__proto.changeItem=function(index,source){
		if (index >-1 && index < this._array.length){
			this._array[index]=source;
			if (index >=this._startIndex && index < this._startIndex+this._cells.length){
				this.renderItem(this.getCell(index),index);
			}
		}
	}

	/**
	*设置单元格数据源。
	*@param index 单元格索引。
	*@param source 单元格数据源。
	*/
	__proto.setItem=function(index,source){
		this.changeItem(index,source);
	}

	/**
	*添加单元格数据源。
	*@param souce 数据源。
	*/
	__proto.addItem=function(souce){
		this._array.push(souce);
		this.array=this._array;
	}

	/**
	*添加单元格数据源到对应的数据索引处。
	*@param souce 单元格数据源。
	*@param index 索引。
	*/
	__proto.addItemAt=function(souce,index){
		this._array.splice(index,0,souce);
		this.array=this._array;
	}

	/**
	*通过数据源索引删除单元格数据源。
	*@param index 需要删除的数据源索引值。
	*/
	__proto.deleteItem=function(index){
		this._array.splice(index,1);
		this.array=this._array;
	}

	/**
	*通过可视单元格索引，获取单元格。
	*@param index 可视单元格索引。
	*@return 单元格对象。
	*/
	__proto.getCell=function(index){
		this.runCallLater(this.changeCells);
		if (index >-1 && this._cells){
			return this._cells[(index-this._startIndex)% this._cells.length];
		}
		return null;
	}

	/**
	*<p>滚动列表，以设定的数据索引对应的单元格为当前可视列表的第一项。</p>
	*@param index 单元格在数据列表中的索引。
	*/
	__proto.scrollTo=function(index){
		if (this._scrollBar){
			var numX=this._isVertical ? this.repeatX :this.repeatY;
			this._scrollBar.value=Math.floor(index / numX)*this._cellSize;
			}else {
			this.startIndex=index;
		}
	}

	/**
	*<p>缓动滚动列表，以设定的数据索引对应的单元格为当前可视列表的第一项。</p>
	*@param index 单元格在数据列表中的索引。
	*@param time 缓动时间。
	*@param complete 缓动结束回掉
	*/
	__proto.tweenTo=function(index,time,complete){
		(time===void 0)&& (time=200);
		if (this._scrollBar){
			var numX=this._isVertical ? this.repeatX :this.repeatY;
			Tween.to(this._scrollBar,{value:Math.floor(index / numX)*this._cellSize},time,null,complete,0,true);
			}else {
			this.startIndex=index;
			if (complete)complete.run();
		}
	}

	/**@private */
	__proto._setCellChanged=function(){
		if (!this._cellChanged){
			this._cellChanged=true;
			this.callLater(this.changeCells);
		}
	}

	__proto.commitMeasure=function(){
		this.runCallLater(this.changeCells);
	}

	/**@inheritDoc */
	__getset(0,__proto,'cacheAs',_super.prototype._$get_cacheAs,function(value){
		Laya.superSet(Box,this,'cacheAs',value);
		if (this._scrollBar){
			this._usedCache=null;
			if (value!=="none")this._scrollBar.on("start",this,this.onScrollStart);
			else this._scrollBar.off("start",this,this.onScrollStart);
		}
	});

	/**
	*获取对 <code>List</code> 组件所包含的内容容器 <code>Box</code> 组件的引用。
	*/
	__getset(0,__proto,'content',function(){
		return this._content;
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		if (value !=this._height){
			Laya.superSet(Box,this,'height',value);
			this._setCellChanged();
		}
	});

	/**
	*单元格渲染器。
	*<p><b>取值：</b>
	*<ol>
	*<li>单元格类对象。</li>
	*<li> UI 的 JSON 描述。</li>
	*</ol></p>
	*/
	__getset(0,__proto,'itemRender',function(){
		return this._itemRender;
		},function(value){
		if (this._itemRender !=value){
			this._itemRender=value;
			for (var i=this._cells.length-1;i >-1;i--){
				this._cells[i].destroy();
			}
			this._cells.length=0;
			this._setCellChanged();
		}
	});

	/**
	*垂直方向滚动条皮肤。
	*/
	__getset(0,__proto,'vScrollBarSkin',function(){
		return this._scrollBar ? this._scrollBar.skin :null;
		},function(value){
		this._removePreScrollBar();
		var scrollBar=new VScrollBar();
		scrollBar.name="scrollBar";
		scrollBar.right=0;
		if (value && value !=" ")
			scrollBar.skin=value;
		this.scrollBar=scrollBar;
		this.addChild(scrollBar);
		this._setCellChanged();
	});

	/**
	*列表的当前页码。
	*/
	__getset(0,__proto,'page',function(){
		return this._page;
		},function(value){
		this._page=value
		if (this._array){
			this._page=value > 0 ? value :0;
			this._page=this._page < this.totalPage ? this._page :this.totalPage-1;
			this.startIndex=this._page *this.repeatX *this.repeatY;
		}
	});

	/**
	*水平方向滚动条皮肤。
	*/
	__getset(0,__proto,'hScrollBarSkin',function(){
		return this._scrollBar ? this._scrollBar.skin :null;
		},function(value){
		this._removePreScrollBar();
		var scrollBar=new HScrollBar();
		scrollBar.name="scrollBar";
		scrollBar.bottom=0;
		if (value && value !=" ")
			scrollBar.skin=value;
		this.scrollBar=scrollBar;
		this.addChild(scrollBar);
		this._setCellChanged();
	});

	/**
	*水平方向显示的单元格数量。
	*/
	__getset(0,__proto,'repeatX',function(){
		return this._repeatX > 0 ? this._repeatX :this._repeatX2 > 0 ? this._repeatX2 :1;
		},function(value){
		this._repeatX=value;
		this._setCellChanged();
	});

	/**
	*获取对 <code>List</code> 组件所包含的滚动条 <code>ScrollBar</code> 组件的引用。
	*/
	__getset(0,__proto,'scrollBar',function(){
		return this._scrollBar;
		},function(value){
		if (this._scrollBar !=value){
			this._scrollBar=value;
			if (value){
				this._isVertical=this._scrollBar.isVertical;
				this.addChild(this._scrollBar);
				this._scrollBar.on("change",this,this.onScrollBarChange);
			}
		}
	});

	/**@inheritDoc */
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		if (value !=this._width){
			Laya.superSet(Box,this,'width',value);
			this._setCellChanged();
		}
	});

	/**
	*垂直方向显示的单元格数量。
	*/
	__getset(0,__proto,'repeatY',function(){
		return this._repeatY > 0 ? this._repeatY :this._repeatY2 > 0 ? this._repeatY2 :1;
		},function(value){
		this._repeatY=value;
		this._setCellChanged();
	});

	/**
	*水平方向显示的单元格之间的间距（以像素为单位）。
	*/
	__getset(0,__proto,'spaceX',function(){
		return this._spaceX;
		},function(value){
		this._spaceX=value;
		this._setCellChanged();
	});

	/**
	*垂直方向显示的单元格之间的间距（以像素为单位）。
	*/
	__getset(0,__proto,'spaceY',function(){
		return this._spaceY;
		},function(value){
		this._spaceY=value;
		this._setCellChanged();
	});

	/**
	*表示当前选择的项索引。selectedIndex值更改会引起list重新渲染
	*/
	__getset(0,__proto,'selectedIndex',function(){
		return this._selectedIndex;
		},function(value){
		if (this._selectedIndex !=value){
			this._selectedIndex=value;
			this.changeSelectStatus();
			this.event("change");
			this.selectHandler && this.selectHandler.runWith(value);
			this.startIndex=this._startIndex;
		}
	});

	/**
	*当前选中的单元格数据源。
	*/
	__getset(0,__proto,'selectedItem',function(){
		return this._selectedIndex !=-1 ? this._array[this._selectedIndex] :null;
		},function(value){
		this.selectedIndex=this._array.indexOf(value);
	});

	/**
	*列表的数据总个数。
	*/
	__getset(0,__proto,'length',function(){
		return this._array ? this._array.length :0;
	});

	/**
	*获取或设置当前选择的单元格对象。
	*/
	__getset(0,__proto,'selection',function(){
		return this.getCell(this._selectedIndex);
		},function(value){
		this.selectedIndex=this._startIndex+this._cells.indexOf(value);
	});

	/**
	*当前显示的单元格列表的开始索引。
	*/
	__getset(0,__proto,'startIndex',function(){
		return this._startIndex;
		},function(value){
		this._startIndex=value > 0 ? value :0;
		this.callLater(this.renderItems);
	});

	/**
	*列表数据源。
	*/
	__getset(0,__proto,'array',function(){
		return this._array;
		},function(value){
		this.runCallLater(this.changeCells);
		this._array=value || [];
		var length=this._array.length;
		this.totalPage=Math.ceil(length / (this.repeatX *this.repeatY));
		this._selectedIndex=this._selectedIndex < length ? this._selectedIndex :length-1;
		this.startIndex=this._startIndex;
		if (this._scrollBar){
			this._scrollBar.stopScroll();
			var numX=this._isVertical ? this.repeatX :this.repeatY;
			var numY=this._isVertical ? this.repeatY :this.repeatX;
			var lineCount=Math.ceil(length / numX);
			var total=this._cellOffset > 0 ? this.totalPage+1 :this.totalPage;
			if (total > 1){
				this._scrollBar.scrollSize=this._cellSize;
				this._scrollBar.thumbPercent=numY / lineCount;
				this._scrollBar.setScroll(0,(lineCount-numY)*this._cellSize+this._cellOffset,this._scrollBar.value);
				this._scrollBar.target=this._content;
				}else {
				this._scrollBar.setScroll(0,0,0);
				this._scrollBar.target=this._content;
			}
		}
	});

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if (((typeof value=='number')&& Math.floor(value)==value)|| (typeof value=='string'))this.selectedIndex=parseInt(value);
		else if ((value instanceof Array))this.array=value
		else Laya.superSet(Box,this,'dataSource',value);
	});

	/**
	*单元格集合。
	*/
	__getset(0,__proto,'cells',function(){
		this.runCallLater(this.changeCells);
		return this._cells;
	});

	return List;
})(Box)


//class laya.ui.Panel extends laya.ui.Box
var Panel=(function(_super){
	function Panel(){
		/**@private */
		this._content=null;
		/**@private */
		this._vScrollBar=null;
		/**@private */
		this._hScrollBar=null;
		/**@private */
		this._scrollChanged=false;
		/**@private */
		this._usedCache=null;
		Panel.__super.call(this);
		this.width=this.height=100;
	}

	__class(Panel,'laya.ui.Panel',_super);
	var __proto=Panel.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		laya.ui.UIComponent.prototype.destroy.call(this,destroyChild);
		this._content && this._content.destroy(destroyChild);
		this._vScrollBar && this._vScrollBar.destroy(destroyChild);
		this._hScrollBar && this._hScrollBar.destroy(destroyChild);
		this._vScrollBar=null;
		this._hScrollBar=null;
		this._content=null;
	}

	/**@inheritDoc */
	__proto.destroyChildren=function(){
		this._content.destroyChildren();
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		laya.display.Node.prototype.addChild.call(this,this._content=new Box());
	}

	/**@inheritDoc */
	__proto.addChild=function(child){
		child.on("resize",this,this.onResize);
		this._setScrollChanged();
		return this._content.addChild(child);
	}

	/**
	*@private
	*子对象的 <code>Event.RESIZE</code> 事件侦听处理函数。
	*/
	__proto.onResize=function(){
		this._setScrollChanged();
	}

	/**@inheritDoc */
	__proto.addChildAt=function(child,index){
		child.on("resize",this,this.onResize);
		this._setScrollChanged();
		return this._content.addChildAt(child,index);
	}

	/**@inheritDoc */
	__proto.removeChild=function(child){
		child.off("resize",this,this.onResize);
		this._setScrollChanged();
		return this._content.removeChild(child);
	}

	/**@inheritDoc */
	__proto.removeChildAt=function(index){
		this.getChildAt(index).off("resize",this,this.onResize);
		this._setScrollChanged();
		return this._content.removeChildAt(index);
	}

	/**@inheritDoc */
	__proto.removeChildren=function(beginIndex,endIndex){
		(beginIndex===void 0)&& (beginIndex=0);
		(endIndex===void 0)&& (endIndex=0x7fffffff);
		this._content.removeChildren(beginIndex,endIndex);
		this._setScrollChanged();
		return this;
	}

	/**@inheritDoc */
	__proto.getChildAt=function(index){
		return this._content.getChildAt(index);
	}

	/**@inheritDoc */
	__proto.getChildByName=function(name){
		return this._content.getChildByName(name);
	}

	/**@inheritDoc */
	__proto.getChildIndex=function(child){
		return this._content.getChildIndex(child);
	}

	/**@private */
	__proto.changeScroll=function(){
		this._scrollChanged=false;
		var contentW=this.contentWidth || 1;
		var contentH=this.contentHeight || 1;
		var vscroll=this._vScrollBar;
		var hscroll=this._hScrollBar;
		var vShow=vscroll && contentH > this._height;
		var hShow=hscroll && contentW > this._width;
		var showWidth=vShow ? this._width-vscroll.width :this._width;
		var showHeight=hShow ? this._height-hscroll.height :this._height;
		if (vscroll){
			vscroll.x=this._width-vscroll.width;
			vscroll.y=0;
			vscroll.height=this._height-(hShow ? hscroll.height :0);
			vscroll.scrollSize=Math.max(this._height *0.033,1);
			vscroll.thumbPercent=showHeight / contentH;
			vscroll.setScroll(0,contentH-showHeight,vscroll.value);
		}
		if (hscroll){
			hscroll.x=0;
			hscroll.y=this._height-hscroll.height;
			hscroll.width=this._width-(vShow ? vscroll.width :0);
			hscroll.scrollSize=Math.max(this._width *0.033,1);
			hscroll.thumbPercent=showWidth / contentW;
			hscroll.setScroll(0,contentW-showWidth,hscroll.value);
		}
	}

	/**@inheritDoc */
	__proto._sizeChanged=function(){
		laya.ui.UIComponent.prototype._sizeChanged.call(this);
		this.setContentSize(this._width,this._height);
	}

	/**
	*@private
	*设置内容的宽度、高度（以像素为单位）。
	*@param width 宽度。
	*@param height 高度。
	*/
	__proto.setContentSize=function(width,height){
		var content=this._content;
		content.width=width;
		content.height=height;
		content._style.scrollRect || (content.scrollRect=Rectangle.create());
		content._style.scrollRect.setTo(0,0,width,height);
		content.scrollRect=content.scrollRect;
	}

	/**
	*@private
	*滚动条的<code><code>Event.MOUSE_DOWN</code>事件侦听处理函数。</code>事件侦听处理函数。
	*@param scrollBar 滚动条对象。
	*@param e Event 对象。
	*/
	__proto.onScrollBarChange=function(scrollBar){
		var rect=this._content._style.scrollRect;
		if (rect){
			var start=Math.round(scrollBar.value);
			scrollBar.isVertical ? rect.y=start :rect.x=start;
			this._content.scrollRect=rect;
		}
	}

	/**
	*<p>滚动内容容器至设定的垂直、水平方向滚动条位置。</p>
	*@param x 水平方向滚动条属性value值。滚动条位置数字。
	*@param y 垂直方向滚动条属性value值。滚动条位置数字。
	*/
	__proto.scrollTo=function(x,y){
		(x===void 0)&& (x=0);
		(y===void 0)&& (y=0);
		if (this.vScrollBar)this.vScrollBar.value=y;
		if (this.hScrollBar)this.hScrollBar.value=x;
	}

	/**
	*刷新滚动内容。
	*/
	__proto.refresh=function(){
		this.changeScroll();
	}

	__proto.onScrollStart=function(){
		this._usedCache || (this._usedCache=Laya.superGet(Box,this,'cacheAs'));
		Laya.superSet(Box,this,'cacheAs',"none");
		this._hScrollBar && this._hScrollBar.once("end",this,this.onScrollEnd);
		this._vScrollBar && this._vScrollBar.once("end",this,this.onScrollEnd);
	}

	__proto.onScrollEnd=function(){
		Laya.superSet(Box,this,'cacheAs',this._usedCache);
	}

	/**@private */
	__proto._setScrollChanged=function(){
		if (!this._scrollChanged){
			this._scrollChanged=true;
			this.callLater(this.changeScroll);
		}
	}

	/**@inheritDoc */
	__getset(0,__proto,'numChildren',function(){
		return this._content.numChildren;
	});

	/**
	*水平方向滚动条皮肤。
	*/
	__getset(0,__proto,'hScrollBarSkin',function(){
		return this._hScrollBar ? this._hScrollBar.skin :null;
		},function(value){
		if (this._hScrollBar==null){
			laya.display.Node.prototype.addChild.call(this,this._hScrollBar=new HScrollBar());
			this._hScrollBar.on("change",this,this.onScrollBarChange,[this._hScrollBar]);
			this._hScrollBar.target=this._content;
			this._setScrollChanged();
		}
		this._hScrollBar.skin=value;
	});

	/**
	*@private
	*获取内容宽度（以像素为单位）。
	*/
	__getset(0,__proto,'contentWidth',function(){
		var max=0;
		for (var i=this._content.numChildren-1;i >-1;i--){
			var comp=this._content.getChildAt(i);
			max=Math.max(comp._x+comp.width *comp.scaleX,max);
		}
		return max;
	});

	/**
	*@private
	*获取内容高度（以像素为单位）。
	*/
	__getset(0,__proto,'contentHeight',function(){
		var max=0;
		for (var i=this._content.numChildren-1;i >-1;i--){
			var comp=this._content.getChildAt(i);
			max=Math.max(comp._y+comp.height *comp.scaleY,max);
		}
		return max;
	});

	/**
	*@inheritDoc
	*/
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(Box,this,'width',value);
		this._setScrollChanged();
	});

	/**
	*水平方向滚动条对象。
	*/
	__getset(0,__proto,'hScrollBar',function(){
		return this._hScrollBar;
	});

	/**
	*获取内容容器对象。
	*/
	__getset(0,__proto,'content',function(){
		return this._content;
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(Box,this,'height',value);
		this._setScrollChanged();
	});

	/**
	*垂直方向滚动条皮肤。
	*/
	__getset(0,__proto,'vScrollBarSkin',function(){
		return this._vScrollBar ? this._vScrollBar.skin :null;
		},function(value){
		if (this._vScrollBar==null){
			laya.display.Node.prototype.addChild.call(this,this._vScrollBar=new VScrollBar());
			this._vScrollBar.on("change",this,this.onScrollBarChange,[this._vScrollBar]);
			this._vScrollBar.target=this._content;
			this._setScrollChanged();
		}
		this._vScrollBar.skin=value;
	});

	/**
	*垂直方向滚动条对象。
	*/
	__getset(0,__proto,'vScrollBar',function(){
		return this._vScrollBar;
	});

	/**@inheritDoc */
	__getset(0,__proto,'cacheAs',_super.prototype._$get_cacheAs,function(value){
		Laya.superSet(Box,this,'cacheAs',value);
		this._usedCache=null;
		if (value!=="none"){
			this._hScrollBar && this._hScrollBar.on("start",this,this.onScrollStart);
			this._vScrollBar && this._vScrollBar.on("start",this,this.onScrollStart);
			}else {
			this._hScrollBar && this._hScrollBar.off("start",this,this.onScrollStart);
			this._vScrollBar && this._vScrollBar.off("start",this,this.onScrollStart);
		}
	});

	return Panel;
})(Box)


//class laya.ui.HScrollBar extends laya.ui.ScrollBar
var HScrollBar=(function(_super){
	function HScrollBar(){
		HScrollBar.__super.call(this);;
	}

	__class(HScrollBar,'laya.ui.HScrollBar',_super);
	var __proto=HScrollBar.prototype;
	/**@inheritDoc */
	__proto.initialize=function(){
		_super.prototype.initialize.call(this);
		this.slider.isVertical=false;
	}

	return HScrollBar;
})(ScrollBar)


//class laya.ui.UIGroup extends laya.ui.Box
var UIGroup=(function(_super){
	function UIGroup(labels,skin){
		/**
		*改变 <code>Group</code> 的选择项时执行的处理器，(默认返回参数： 项索引（index:int）)。
		*/
		this.selectHandler=null;
		/**@private */
		this._items=null;
		/**@private */
		this._selectedIndex=-1;
		/**@private */
		this._skin=null;
		/**@private */
		this._direction="horizontal";
		/**@private */
		this._space=0;
		/**@private */
		this._labels=null;
		/**@private */
		this._labelColors=null;
		/**@private */
		this._labelFont=null;
		/**@private */
		this._labelStrokeColor=null;
		/**@private */
		this._strokeColors=null;
		/**@private */
		this._labelStroke=NaN;
		/**@private */
		this._labelSize=0;
		/**@private */
		this._labelBold=false;
		/**@private */
		this._labelPadding=null;
		/**@private */
		this._labelAlign=null;
		/**@private */
		this._stateNum=0;
		/**@private */
		this._labelChanged=false;
		UIGroup.__super.call(this);
		this.skin=skin;
		this.labels=labels;
	}

	__class(UIGroup,'laya.ui.UIGroup',_super);
	var __proto=UIGroup.prototype;
	Laya.imps(__proto,{"laya.ui.IItem":true})
	/**@inheritDoc */
	__proto.preinitialize=function(){
		this.mouseEnabled=true;
	}

	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		laya.ui.UIComponent.prototype.destroy.call(this,destroyChild);
		this._items && (this._items.length=0);
		this._items=null;
		this.selectHandler=null;
	}

	/**
	*添加一个项对象，返回此项对象的索引id。
	*
	*@param item 需要添加的项对象。
	*@param autoLayOut 是否自动布局，如果为true，会根据 <code>direction</code> 和 <code>space</code> 属性计算item的位置。
	*@return
	*/
	__proto.addItem=function(item,autoLayOut){
		(autoLayOut===void 0)&& (autoLayOut=true);
		var display=item;
		var index=this._items.length;
		display.name="item"+index;
		this.addChild(display);
		this.initItems();
		if (autoLayOut && index > 0){
			var preItem=this._items [index-1];
			if (this._direction=="horizontal"){
				display.x=preItem._x+preItem.width+this._space;
				}else {
				display.y=preItem._y+preItem.height+this._space;
			}
			}else {
			if (autoLayOut){
				display.x=0;
				display.y=0;
			}
		}
		return index;
	}

	/**
	*删除一个项对象。
	*@param item 需要删除的项对象。
	*@param autoLayOut 是否自动布局，如果为true，会根据 <code>direction</code> 和 <code>space</code> 属性计算item的位置。
	*/
	__proto.delItem=function(item,autoLayOut){
		(autoLayOut===void 0)&& (autoLayOut=true);
		var index=this._items.indexOf(item);
		if (index !=-1){
			var display=item;
			this.removeChild(display);
			for (var i=index+1,n=this._items.length;i < n;i++){
				var child=this._items [i];
				child.name="item"+(i-1);
				if (autoLayOut){
					if (this._direction=="horizontal"){
						child.x-=display.width+this._space;
						}else {
						child.y-=display.height+this._space;
					}
				}
			}
			this.initItems();
			if (this._selectedIndex >-1){
				var newIndex=0;
				newIndex=this._selectedIndex < this._items.length ? this._selectedIndex :(this._selectedIndex-1);
				this._selectedIndex=-1;
				this.selectedIndex=newIndex;
			}
		}
	}

	__proto._afterInited=function(){
		this.initItems();
	}

	/**
	*初始化项对象们。
	*/
	__proto.initItems=function(){
		this._items || (this._items=[]);
		this._items.length=0;
		for (var i=0;i < 10000;i++){
			var item=this.getChildByName("item"+i);
			if (item==null)break ;
			this._items.push(item);
			item.selected=(i===this._selectedIndex);
			item.clickHandler=Handler.create(this,this.itemClick,[i],false);
		}
	}

	/**
	*@private
	*项对象的点击事件侦听处理函数。
	*@param index 项索引。
	*/
	__proto.itemClick=function(index){
		this.selectedIndex=index;
	}

	/**
	*@private
	*通过对象的索引设置项对象的 <code>selected</code> 属性值。
	*@param index 需要设置的项对象的索引。
	*@param selected 表示项对象的选中状态。
	*/
	__proto.setSelect=function(index,selected){
		if (this._items && index >-1 && index < this._items.length)this._items[index].selected=selected;
	}

	__proto._skinLoaded=function(){
		this._setLabelChanged();
		this.event("loaded");
	}

	/**
	*@private
	*创建一个项显示对象。
	*@param skin 项对象的皮肤。
	*@param label 项对象标签。
	*/
	__proto.createItem=function(skin,label){
		return null;
	}

	/**
	*@private
	*更改项对象的属性值。
	*/
	__proto.changeLabels=function(){
		this._labelChanged=false;
		if (this._items){
			var left=0
			for (var i=0,n=this._items.length;i < n;i++){
				var btn=this._items [i];
				this._skin && (btn.skin=this._skin);
				this._labelColors && (btn.labelColors=this._labelColors);
				this._labelSize && (btn.labelSize=this._labelSize);
				this._labelStroke && (btn.labelStroke=this._labelStroke);
				this._labelStrokeColor && (btn.labelStrokeColor=this._labelStrokeColor);
				this._strokeColors && (btn.strokeColors=this._strokeColors);
				this._labelBold && (btn.labelBold=this._labelBold);
				this._labelPadding && (btn.labelPadding=this._labelPadding);
				this._labelAlign && (btn.labelAlign=this._labelAlign);
				this._stateNum && (btn.stateNum=this._stateNum);
				this._labelFont && (btn.labelFont=this._labelFont);
				if (this._direction==="horizontal"){
					btn.y=0;
					btn.x=left;
					left+=btn.width+this._space;
					}else {
					btn.x=0;
					btn.y=left;
					left+=btn.height+this._space;
				}
			}
		}
		this._sizeChanged();
	}

	/**@inheritDoc */
	__proto.commitMeasure=function(){
		this.runCallLater(this.changeLabels);
	}

	/**@private */
	__proto._setLabelChanged=function(){
		if (!this._labelChanged){
			this._labelChanged=true;
			this.callLater(this.changeLabels);
		}
	}

	/**
	*<p>描边颜色，以字符串表示。</p>
	*默认值为 "#000000"（黑色）;
	*@see laya.display.Text.strokeColor()
	*/
	__getset(0,__proto,'labelStrokeColor',function(){
		return this._labelStrokeColor;
		},function(value){
		if (this._labelStrokeColor !=value){
			this._labelStrokeColor=value;
			this._setLabelChanged();
		}
	});

	/**
	*@copy laya.ui.Image#skin
	*/
	__getset(0,__proto,'skin',function(){
		return this._skin;
		},function(value){
		if (this._skin !=value){
			this._skin=value;
			if (this._skin&&!Loader.getRes(this._skin)){
				Laya.loader.load(this._skin,Handler.create(this,this._skinLoaded),null,"image",1);
				}else{
				this._skinLoaded();
			}
		}
	});

	/**
	*表示当前选择的项索引。默认值为-1。
	*/
	__getset(0,__proto,'selectedIndex',function(){
		return this._selectedIndex;
		},function(value){
		if (this._selectedIndex !=value){
			this.setSelect(this._selectedIndex,false);
			this._selectedIndex=value;
			this.setSelect(value,true);
			this.event("change");
			this.selectHandler && this.selectHandler.runWith(this._selectedIndex);
		}
	});

	/**
	*标签集合字符串。以逗号做分割，如"item0,item1,item2,item3,item4,item5"。
	*/
	__getset(0,__proto,'labels',function(){
		return this._labels;
		},function(value){
		if (this._labels !=value){
			this._labels=value;
			this.removeChildren();
			this._setLabelChanged();
			if (this._labels){
				var a=this._labels.split(",");
				for (var i=0,n=a.length;i < n;i++){
					var item=this.createItem(this._skin,a[i]);
					item.name="item"+i;
					this.addChild(item);
				}
			}
			this.initItems();
		}
	});

	/**
	*<p>表示各个状态下的描边颜色。</p>
	*@see laya.display.Text.strokeColor()
	*/
	__getset(0,__proto,'strokeColors',function(){
		return this._strokeColors;
		},function(value){
		if (this._strokeColors !=value){
			this._strokeColors=value;
			this._setLabelChanged();
		}
	});

	/**
	*@copy laya.ui.Button#labelColors()
	*/
	__getset(0,__proto,'labelColors',function(){
		return this._labelColors;
		},function(value){
		if (this._labelColors !=value){
			this._labelColors=value;
			this._setLabelChanged();
		}
	});

	/**
	*<p>描边宽度（以像素为单位）。</p>
	*默认值0，表示不描边。
	*@see laya.display.Text.stroke()
	*/
	__getset(0,__proto,'labelStroke',function(){
		return this._labelStroke;
		},function(value){
		if (this._labelStroke !=value){
			this._labelStroke=value;
			this._setLabelChanged();
		}
	});

	/**
	*表示按钮文本标签的字体大小。
	*/
	__getset(0,__proto,'labelSize',function(){
		return this._labelSize;
		},function(value){
		if (this._labelSize !=value){
			this._labelSize=value;
			this._setLabelChanged();
		}
	});

	/**
	*表示按钮的状态值，以数字表示，默认为3态。
	*@see laya.ui.Button#stateNum
	*/
	__getset(0,__proto,'stateNum',function(){
		return this._stateNum;
		},function(value){
		if (this._stateNum !=value){
			this._stateNum=value;
			this._setLabelChanged();
		}
	});

	/**
	*表示按钮文本标签是否为粗体字。
	*/
	__getset(0,__proto,'labelBold',function(){
		return this._labelBold;
		},function(value){
		if (this._labelBold !=value){
			this._labelBold=value;
			this._setLabelChanged();
		}
	});

	/**
	*表示按钮文本标签的字体名称，以字符串形式表示。
	*@see laya.display.Text.font()
	*/
	__getset(0,__proto,'labelFont',function(){
		return this._labelFont;
		},function(value){
		if (this._labelFont !=value){
			this._labelFont=value;
			this._setLabelChanged();
		}
	});

	/**
	*表示按钮文本标签的边距。
	*<p><b>格式：</b>"上边距,右边距,下边距,左边距"。</p>
	*/
	__getset(0,__proto,'labelPadding',function(){
		return this._labelPadding;
		},function(value){
		if (this._labelPadding !=value){
			this._labelPadding=value;
			this._setLabelChanged();
		}
	});

	/**
	*布局方向。
	*<p>默认值为"horizontal"。</p>
	*<p><b>取值：</b>
	*<li>"horizontal"：表示水平布局。</li>
	*<li>"vertical"：表示垂直布局。</li>
	*</p>
	*/
	__getset(0,__proto,'direction',function(){
		return this._direction;
		},function(value){
		this._direction=value;
		this._setLabelChanged();
	});

	/**
	*项对象们之间的间隔（以像素为单位）。
	*/
	__getset(0,__proto,'space',function(){
		return this._space;
		},function(value){
		this._space=value;
		this._setLabelChanged();
	});

	/**
	*项对象们的存放数组。
	*/
	__getset(0,__proto,'items',function(){
		return this._items;
	});

	/**
	*获取或设置当前选择的项对象。
	*/
	__getset(0,__proto,'selection',function(){
		return this._selectedIndex >-1 && this._selectedIndex < this._items.length ? this._items[this._selectedIndex] :null;
		},function(value){
		this.selectedIndex=this._items.indexOf(value);
	});

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if (((typeof value=='number')&& Math.floor(value)==value)|| (typeof value=='string'))this.selectedIndex=parseInt(value);
		else if ((value instanceof Array))this.labels=(value).join(",");
		else Laya.superSet(Box,this,'dataSource',value);
	});

	return UIGroup;
})(Box)


//class laya.ui.Radio extends laya.ui.Button
var Radio=(function(_super){
	function Radio(skin,label){
		/**@private */
		this._value=null;
		(label===void 0)&& (label="");
		Radio.__super.call(this,skin,label);
	}

	__class(Radio,'laya.ui.Radio',_super);
	var __proto=Radio.prototype;
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._value=null;
	}

	/**@inheritDoc */
	__proto.preinitialize=function(){
		laya.ui.UIComponent.prototype.preinitialize.call(this);
		this.toggle=false;
		this._autoSize=false;
	}

	/**@inheritDoc */
	__proto.initialize=function(){
		_super.prototype.initialize.call(this);
		this.createText();
		this._text.align="left";
		this._text.valign="top";
		this._text.width=0;
		this.on("click",this,this.onClick);
	}

	/**
	*@private
	*对象的<code>Event.CLICK</code>事件侦听处理函数。
	*/
	__proto.onClick=function(e){
		this.selected=true;
	}

	/**
	*获取或设置 <code>Radio</code> 关联的可选用户定义值。
	*/
	__getset(0,__proto,'value',function(){
		return this._value !=null ? this._value :this.label;
		},function(obj){
		this._value=obj;
	});

	return Radio;
})(Button)


//class laya.ui.HSlider extends laya.ui.Slider
var HSlider=(function(_super){
	/**
	*创建一个 <code>HSlider</code> 类实例。
	*@param skin 皮肤。
	*/
	function HSlider(skin){
		HSlider.__super.call(this,skin);
		this.isVertical=false;
	}

	__class(HSlider,'laya.ui.HSlider',_super);
	return HSlider;
})(Slider)


//class laya.ui.Tree extends laya.ui.Box
var Tree=(function(_super){
	function Tree(){
		/**@private */
		this._list=null;
		/**@private */
		this._source=null;
		/**@private */
		this._renderHandler=null;
		/**@private */
		this._spaceLeft=10;
		/**@private */
		this._spaceBottom=0;
		/**@private */
		this._keepStatus=true;
		Tree.__super.call(this);
		this.width=this.height=200;
	}

	__class(Tree,'laya.ui.Tree',_super);
	var __proto=Tree.prototype;
	Laya.imps(__proto,{"laya.ui.IRender":true})
	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		laya.ui.UIComponent.prototype.destroy.call(this,destroyChild);
		this._list && this._list.destroy(destroyChild);
		this._list=null;
		this._source=null;
		this._renderHandler=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this._list=new List());
		this._list.renderHandler=Handler.create(this,this.renderItem,null,false);
		this._list.repeatX=1;
		this._list.on("change",this,this.onListChange);
	}

	/**
	*@private
	*此对象包含的<code>List</code>实例的<code>Event.CHANGE</code>事件侦听处理函数。
	*/
	__proto.onListChange=function(e){
		this.event("change");
	}

	/**
	*@private
	*获取数据源集合。
	*/
	__proto.getArray=function(){
		var arr=[];
		var item;
		for(var $each_item in this._source){
			item=this._source[$each_item];
			if (this.getParentOpenStatus(item)){
				item.x=this._spaceLeft *this.getDepth(item);
				arr.push(item);
			}
		}
		return arr;
	}

	/**
	*@private
	*获取项对象的深度。
	*/
	__proto.getDepth=function(item,num){
		(num===void 0)&& (num=0);
		if (item.nodeParent==null)return num;
		else return this.getDepth(item.nodeParent,num+1);
	}

	/**
	*@private
	*获取项对象的上一级的打开状态。
	*/
	__proto.getParentOpenStatus=function(item){
		var parent=item.nodeParent;
		if (parent==null){
			return true;
			}else {
			if (parent.isOpen){
				if (parent.nodeParent !=null)return this.getParentOpenStatus(parent);
				else return true;
				}else {
				return false;
			}
		}
	}

	/**
	*@private
	*渲染一个项对象。
	*@param cell 一个项对象。
	*@param index 项的索引。
	*/
	__proto.renderItem=function(cell,index){
		var item=cell.dataSource;
		if (item){
			cell.left=item.x;
			var arrow=cell.getChildByName("arrow");
			if (arrow){
				if (item.hasChild){
					arrow.visible=true;
					arrow.index=item.isOpen ? 1 :0;
					arrow.tag=index;
					arrow.off("click",this,this.onArrowClick);
					arrow.on("click",this,this.onArrowClick);
					}else {
					arrow.visible=false;
				}
			};
			var folder=cell.getChildByName("folder");
			if (folder){
				if (folder.clipY==2){
					folder.index=item.isDirectory ? 0 :1;
					}else {
					folder.index=item.isDirectory ? item.isOpen ? 1 :0 :2;
				}
			}
			this._renderHandler && this._renderHandler.runWith([cell,index]);
		}
	}

	/**
	*@private
	*/
	__proto.onArrowClick=function(e){
		var arrow=e.currentTarget;
		var index=arrow.tag;
		this._list.array[index].isOpen=!this._list.array[index].isOpen;
		this.event("open");
		this._list.array=this.getArray();
	}

	/**
	*设置指定项索引的项对象的打开状态。
	*@param index 项索引。
	*@param isOpen 是否处于打开状态。
	*/
	__proto.setItemState=function(index,isOpen){
		if (!this._list.array[index])return;
		this._list.array[index].isOpen=isOpen;
		this._list.array=this.getArray();
	}

	/**
	*刷新项列表。
	*/
	__proto.fresh=function(){
		this._list.array=this.getArray();
		this.repaint();
	}

	/**
	*@private
	*解析并处理XML类型的数据源。
	*/
	__proto.parseXml=function(xml,source,nodeParent,isRoot){
		var obj;
		var list=xml.childNodes;
		var childCount=list.length;
		if (!isRoot){
			obj={};
			var list2=xml.attributes;
			var attrs;
			for(var $each_attrs in list2){
				attrs=list2[$each_attrs];
				var prop=attrs.nodeName;
				var value=attrs.nodeValue;
				obj[prop]=value=="true" ? true :value=="false" ? false :value;
			}
			obj.nodeParent=nodeParent;
			if (childCount > 0)obj.isDirectory=true;
			obj.hasChild=childCount > 0;
			source.push(obj);
		}
		for (var i=0;i < childCount;i++){
			var node=list[i];
			this.parseXml(node,source,obj,false);
		}
	}

	/**
	*@private
	*处理数据项的打开状态。
	*/
	__proto.parseOpenStatus=function(oldSource,newSource){
		for (var i=0,n=newSource.length;i < n;i++){
			var newItem=newSource[i];
			if (newItem.isDirectory){
				for (var j=0,m=oldSource.length;j < m;j++){
					var oldItem=oldSource[j];
					if (oldItem.isDirectory && this.isSameParent(oldItem,newItem)&& newItem.label==oldItem.label){
						newItem.isOpen=oldItem.isOpen;
						break ;
					}
				}
			}
		}
	}

	/**
	*@private
	*判断两个项对象在树结构中的父节点是否相同。
	*@param item1 项对象。
	*@param item2 项对象。
	*@return 如果父节点相同值为true，否则值为false。
	*/
	__proto.isSameParent=function(item1,item2){
		if (item1.nodeParent==null && item2.nodeParent==null)return true;
		else if (item1.nodeParent==null || item2.nodeParent==null)return false
		else {
			if (item1.nodeParent.label==item2.nodeParent.label)return this.isSameParent(item1.nodeParent,item2.nodeParent);
			else return false;
		}
	}

	/**
	*更新项列表，显示指定键名的数据项。
	*@param key 键名。
	*/
	__proto.filter=function(key){
		if (Boolean(key)){
			var result=[];
			this.getFilterSource(this._source,result,key);
			this._list.array=result;
			}else {
			this._list.array=this.getArray();
		}
	}

	/**
	*@private
	*获取数据源中指定键名的值。
	*/
	__proto.getFilterSource=function(array,result,key){
		key=key.toLocaleLowerCase();
		var item;
		for(var $each_item in array){
			item=array[$each_item];
			if (!item.isDirectory && String(item.label).toLowerCase().indexOf(key)>-1){
				item.x=0;
				result.push(item);
			}
			if (item.child && item.child.length > 0){
				this.getFilterSource(item.child,result,key);
			}
		}
	}

	/**
	*每一项之间的间隔距离（以像素为单位）。
	*/
	__getset(0,__proto,'spaceBottom',function(){
		return this._list.spaceY;
		},function(value){
		this._list.spaceY=value;
	});

	/**
	*数据源发生变化后，是否保持之前打开状态，默认为true。
	*<p><b>取值：</b>
	*<li>true：保持之前打开状态。</li>
	*<li>false：不保持之前打开状态。</li>
	*</p>
	*/
	__getset(0,__proto,'keepStatus',function(){
		return this._keepStatus;
		},function(value){
		this._keepStatus=value;
	});

	/**
	*此对象包含的<code>List</code>实例的单元格渲染器。
	*<p><b>取值：</b>
	*<ol>
	*<li>单元格类对象。</li>
	*<li> UI 的 JSON 描述。</li>
	*</ol></p>
	*/
	__getset(0,__proto,'itemRender',function(){
		return this._list.itemRender;
		},function(value){
		this._list.itemRender=value;
	});

	/**
	*列表数据源，只包含当前可视节点数据。
	*/
	__getset(0,__proto,'array',function(){
		return this._list.array;
		},function(value){
		if (this._keepStatus && this._list.array && value){
			this.parseOpenStatus(this._list.array,value);
		}
		this._source=value;
		this._list.array=this.getArray();
	});

	/**
	*单元格鼠标事件处理器。
	*<p>默认返回参数（e:Event,index:int）。</p>
	*/
	__getset(0,__proto,'mouseHandler',function(){
		return this._list.mouseHandler;
		},function(value){
		this._list.mouseHandler=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		Laya.superSet(Box,this,'dataSource',value);
	});

	/**
	*数据源，全部节点数据。
	*/
	__getset(0,__proto,'source',function(){
		return this._source;
	});

	/**滚动条*/
	__getset(0,__proto,'scrollBar',function(){
		return this._list.scrollBar;
	});

	/**
	*此对象包含的<code>List</code>实例对象。
	*/
	__getset(0,__proto,'list',function(){
		return this._list;
	});

	/**
	*滚动条皮肤。
	*/
	__getset(0,__proto,'scrollBarSkin',function(){
		return this._list.vScrollBarSkin;
		},function(value){
		this._list.vScrollBarSkin=value;
	});

	/**
	*<code>Tree</code> 实例的渲染处理器。
	*/
	__getset(0,__proto,'renderHandler',function(){
		return this._renderHandler;
		},function(value){
		this._renderHandler=value;
	});

	/**
	*表示当前选择的项索引。
	*/
	__getset(0,__proto,'selectedIndex',function(){
		return this._list.selectedIndex;
		},function(value){
		this._list.selectedIndex=value;
	});

	/**
	*左侧缩进距离（以像素为单位）。
	*/
	__getset(0,__proto,'spaceLeft',function(){
		return this._spaceLeft;
		},function(value){
		this._spaceLeft=value;
	});

	/**
	*当前选中的项对象的数据源。
	*/
	__getset(0,__proto,'selectedItem',function(){
		return this._list.selectedItem;
		},function(value){
		this._list.selectedItem=value;
	});

	/**
	*@inheritDoc
	*/
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(Box,this,'width',value);
		this._list.width=value;
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(Box,this,'height',value);
		this._list.height=value;
	});

	/**
	*xml结构的数据源。
	*/
	__getset(0,__proto,'xml',null,function(value){
		var arr=[];
		this.parseXml(value.childNodes[0],arr,null,true);
		this.array=arr;
	});

	/**
	*表示选择的树节点项的<code>path</code>属性值。
	*/
	__getset(0,__proto,'selectedPath',function(){
		if (this._list.selectedItem){
			return this._list.selectedItem.path;
		}
		return null;
	});

	return Tree;
})(Box)


//class laya.ui.ViewStack extends laya.ui.Box
var ViewStack=(function(_super){
	function ViewStack(){
		/**@private */
		this._items=null;
		/**@private */
		this._selectedIndex=0;
		ViewStack.__super.call(this);
		this._setIndexHandler=Handler.create(this,this.setIndex,null,false);
	}

	__class(ViewStack,'laya.ui.ViewStack',_super);
	var __proto=ViewStack.prototype;
	Laya.imps(__proto,{"laya.ui.IItem":true})
	/**
	*批量设置视图对象。
	*@param views 视图对象数组。
	*/
	__proto.setItems=function(views){
		this.removeChildren();
		var index=0;
		for (var i=0,n=views.length;i < n;i++){
			var item=views[i];
			if (item){
				item.name="item"+index;
				this.addChild(item);
				index++;
			}
		}
		this.initItems();
	}

	/**
	*添加视图。
	*@internal 添加视图对象，并设置此视图对象的<code>name</code> 属性。
	*@param view 需要添加的视图对象。
	*/
	__proto.addItem=function(view){
		view.name="item"+this._items.length;
		this.addChild(view);
		this.initItems();
	}

	__proto._afterInited=function(){
		this.initItems();
	}

	/**
	*初始化视图对象集合。
	*/
	__proto.initItems=function(){
		this._items=[];
		for (var i=0;i < 10000;i++){
			var item=this.getChildByName("item"+i);
			if (item==null){
				break ;
			}
			this._items.push(item);
			item.visible=(i==this._selectedIndex);
		}
	}

	/**
	*@private
	*通过对象的索引设置项对象的 <code>selected</code> 属性值。
	*@param index 需要设置的对象的索引。
	*@param selected 表示对象的选中状态。
	*/
	__proto.setSelect=function(index,selected){
		if (this._items && index >-1 && index < this._items.length){
			this._items[index].visible=selected;
		}
	}

	/**
	*@private
	*设置属性<code>selectedIndex</code>的值。
	*@param index 选中项索引值。
	*/
	__proto.setIndex=function(index){
		this.selectedIndex=index;
	}

	/**@inheritDoc */
	__getset(0,__proto,'dataSource',_super.prototype._$get_dataSource,function(value){
		this._dataSource=value;
		if (((typeof value=='number')&& Math.floor(value)==value)|| (typeof value=='string')){
			this.selectedIndex=parseInt(value);
			}else {
			for (var prop in this._dataSource){
				if (this.hasOwnProperty(prop)){
					this[prop]=this._dataSource[prop];
				}
			}
		}
	});

	/**
	*表示当前视图索引。
	*/
	__getset(0,__proto,'selectedIndex',function(){
		return this._selectedIndex;
		},function(value){
		if (this._selectedIndex !=value){
			this.setSelect(this._selectedIndex,false);
			this._selectedIndex=value;
			this.setSelect(this._selectedIndex,true);
		}
	});

	/**
	*获取或设置当前选择的项对象。
	*/
	__getset(0,__proto,'selection',function(){
		return this._selectedIndex >-1 && this._selectedIndex < this._items.length ? this._items[this._selectedIndex] :null;
		},function(value){
		this.selectedIndex=this._items.indexOf(value);
	});

	/**
	*视图集合数组。
	*/
	__getset(0,__proto,'items',function(){
		return this._items;
	});

	/**
	*索引设置处理器。
	*<p>默认回调参数：index:int</p>
	*/
	__getset(0,__proto,'setIndexHandler',function(){
		return this._setIndexHandler;
		},function(value){
		this._setIndexHandler=value;
	});

	return ViewStack;
})(Box)


//class laya.ui.VScrollBar extends laya.ui.ScrollBar
var VScrollBar=(function(_super){
	function VScrollBar(){
		VScrollBar.__super.call(this);;
	}

	__class(VScrollBar,'laya.ui.VScrollBar',_super);
	return VScrollBar;
})(ScrollBar)


//class laya.ui.TextInput extends laya.ui.Label
var TextInput=(function(_super){
	function TextInput(text){
		/**@private */
		this._bg=null;
		/**@private */
		this._skin=null;
		TextInput.__super.call(this);
		(text===void 0)&& (text="");
		this.text=text;
		this.skin=this.skin;
	}

	__class(TextInput,'laya.ui.TextInput',_super);
	var __proto=TextInput.prototype;
	/**@inheritDoc */
	__proto.preinitialize=function(){
		this.mouseEnabled=true;
	}

	/**@inheritDoc */
	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._bg && this._bg.destroy();
		this._bg=null;
	}

	/**@inheritDoc */
	__proto.createChildren=function(){
		this.addChild(this._tf=new Input());
		this._tf.padding=Styles.inputLabelPadding;
		this._tf.on("input",this,this._onInput);
		this._tf.on("enter",this,this._onEnter);
		this._tf.on("blur",this,this._onBlur);
		this._tf.on("focus",this,this._onFocus);
	}

	/**
	*@private
	*/
	__proto._onFocus=function(){
		this.event("focus",this);
	}

	/**
	*@private
	*/
	__proto._onBlur=function(){
		this.event("blur",this);
	}

	/**
	*@private
	*/
	__proto._onInput=function(){
		this.event("input",this);
	}

	/**
	*@private
	*/
	__proto._onEnter=function(){
		this.event("enter",this);
	}

	/**@inheritDoc */
	__proto.initialize=function(){
		this.width=128;
		this.height=22;
	}

	__proto._skinLoaded=function(){
		this._bg || (this.graphics=this._bg=new AutoBitmap());
		this._bg.source=Loader.getRes(this._skin);
		this._width && (this._bg.width=this._width);
		this._height && (this._bg.height=this._height);
		this.event("loaded");
	}

	/**选中输入框内的文本。*/
	__proto.select=function(){
		(this._tf).select();
	}

	__proto.setSelection=function(startIndex,endIndex){
		(this._tf).setSelection(startIndex,endIndex);
	}

	/**
	*当前文本内容字符串。
	*@see laya.display.Text.text
	*/
	__getset(0,__proto,'text',_super.prototype._$get_text,function(value){
		if (this._tf.text !=value){
			value=value+"";
			this._tf.text=value;
			this.event("change");
		}
	});

	/**
	*表示此对象包含的文本背景 <code>AutoBitmap</code> 组件实例。
	*/
	__getset(0,__proto,'bg',function(){
		return this._bg;
		},function(value){
		this.graphics=this._bg=value;
	});

	/**
	*<p>指示当前是否是文本域。</p>
	*值为true表示当前是文本域，否则不是文本域。
	*/
	__getset(0,__proto,'multiline',function(){
		return (this._tf).multiline;
		},function(value){
		(this._tf).multiline=value;
	});

	/**
	*@copy laya.ui.Image#skin
	*/
	__getset(0,__proto,'skin',function(){
		return this._skin;
		},function(value){
		if (this._skin !=value){
			this._skin=value;
			if (this._skin&&!Loader.getRes(this._skin)){
				Laya.loader.load(this._skin,Handler.create(this,this._skinLoaded),null,"image",1);
				}else{
				this._skinLoaded();
			}
		}
	});

	/**
	*<p>当前实例的背景图（ <code>AutoBitmap</code> ）实例的有效缩放网格数据。</p>
	*<p>数据格式："上边距,右边距,下边距,左边距,是否重复填充(值为0：不重复填充，1：重复填充)"，以逗号分隔。
	*<ul><li>例如："4,4,4,4,1"</li></ul></p>
	*@see laya.ui.AutoBitmap.sizeGrid
	*/
	__getset(0,__proto,'sizeGrid',function(){
		return this._bg && this._bg.sizeGrid ? this._bg.sizeGrid.join(","):null;
		},function(value){
		this._bg || (this.graphics=this._bg=new AutoBitmap());
		this._bg.sizeGrid=UIUtils.fillArray(Styles.defaultSizeGrid,value,Number);
	});

	/**@inheritDoc */
	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(Label,this,'width',value);
		this._bg && (this._bg.width=value);
	});

	/**@inheritDoc */
	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(Label,this,'height',value);
		this._bg && (this._bg.height=value);
	});

	/**
	*设置可编辑状态。
	*/
	__getset(0,__proto,'editable',function(){
		return (this._tf).editable;
		},function(value){
		(this._tf).editable=value;
	});

	/**限制输入的字符。*/
	__getset(0,__proto,'restrict',function(){
		return (this._tf).restrict;
		},function(pattern){
		(this._tf).restrict=pattern;
	});

	/**
	*@copy laya.display.Input#prompt
	*/
	__getset(0,__proto,'prompt',function(){
		return (this._tf).prompt;
		},function(value){
		(this._tf).prompt=value;
	});

	/**
	*@copy laya.display.Input#promptColor
	*/
	__getset(0,__proto,'promptColor',function(){
		return (this._tf).promptColor;
		},function(value){
		(this._tf).promptColor=value;
	});

	/**
	*@copy laya.display.Input#maxChars
	*/
	__getset(0,__proto,'maxChars',function(){
		return (this._tf).maxChars;
		},function(value){
		(this._tf).maxChars=value;
	});

	/**
	*@copy laya.display.Input#focus
	*/
	__getset(0,__proto,'focus',function(){
		return (this._tf).focus;
		},function(value){
		(this._tf).focus=value;
	});

	/**
	*@copy laya.display.Input#type
	*/
	__getset(0,__proto,'type',function(){
		return (this._tf).type;
		},function(value){
		(this._tf).type=value;
	});

	return TextInput;
})(Label)


//class laya.ui.VSlider extends laya.ui.Slider
var VSlider=(function(_super){
	function VSlider(){
		VSlider.__super.call(this);;
	}

	__class(VSlider,'laya.ui.VSlider',_super);
	return VSlider;
})(Slider)


//class laya.ui.HBox extends laya.ui.LayoutBox
var HBox=(function(_super){
	function HBox(){
		HBox.__super.call(this);;
	}

	__class(HBox,'laya.ui.HBox',_super);
	var __proto=HBox.prototype;
	/**@inheritDoc */
	__proto.sortItem=function(items){
		if (items)items.sort(function(a,b){return a.x-b.x;});
	}

	/**@inheritDoc */
	__proto.changeItems=function(){
		this._itemChanged=false;
		var items=[];
		var maxHeight=0;
		for (var i=0,n=this.numChildren;i < n;i++){
			var item=this.getChildAt(i);
			if (item){
				items.push(item);
				maxHeight=this._height?this._height:Math.max(maxHeight,item.height *item.scaleY);
			}
		}
		this.sortItem(items);
		var left=0;
		for (i=0,n=items.length;i < n;i++){
			item=items[i];
			item.x=left;
			left+=item.width *item.scaleX+this._space;
			if (this._align=="top"){
				item.y=0;
				}else if (this._align=="middle"){
				item.y=(maxHeight-item.height *item.scaleY)*0.5;
				}else if (this._align=="bottom"){
				item.y=maxHeight-item.height *item.scaleY;
			}
		}
		this._sizeChanged();
	}

	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		if (this._height !=value){
			Laya.superSet(LayoutBox,this,'height',value);
			this.callLater(this.changeItems);
		}
	});

	HBox.NONE="none";
	HBox.TOP="top";
	HBox.MIDDLE="middle";
	HBox.BOTTOM="bottom";
	return HBox;
})(LayoutBox)


//class laya.ui.VBox extends laya.ui.LayoutBox
var VBox=(function(_super){
	function VBox(){
		VBox.__super.call(this);;
	}

	__class(VBox,'laya.ui.VBox',_super);
	var __proto=VBox.prototype;
	/**@inheritDoc */
	__proto.changeItems=function(){
		this._itemChanged=false;
		var items=[];
		var maxWidth=0;
		for (var i=0,n=this.numChildren;i < n;i++){
			var item=this.getChildAt(i);
			if (item){
				items.push(item);
				maxWidth=this._width?this._width:Math.max(maxWidth,item.width *item.scaleX);
			}
		}
		this.sortItem(items);
		var top=0;
		for (i=0,n=items.length;i < n;i++){
			item=items[i];
			item.y=top;
			top+=item.height *item.scaleY+this._space;
			if (this._align=="left"){
				item.x=0;
				}else if (this._align=="center"){
				item.x=(maxWidth-item.width *item.scaleX)*0.5;
				}else if (this._align=="right"){
				item.x=maxWidth-item.width *item.scaleX;
			}
		}
		this._sizeChanged();
	}

	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		if (this._width !=value){
			Laya.superSet(LayoutBox,this,'width',value);
			this.callLater(this.changeItems);
		}
	});

	VBox.NONE="none";
	VBox.LEFT="left";
	VBox.CENTER="center";
	VBox.RIGHT="right";
	return VBox;
})(LayoutBox)


//class laya.ui.RadioGroup extends laya.ui.UIGroup
var RadioGroup=(function(_super){
	function RadioGroup(){
		RadioGroup.__super.call(this);;
	}

	__class(RadioGroup,'laya.ui.RadioGroup',_super);
	var __proto=RadioGroup.prototype;
	/**@inheritDoc */
	__proto.createItem=function(skin,label){
		return new Radio(skin,label);
	}

	return RadioGroup;
})(UIGroup)


//class laya.ui.Tab extends laya.ui.UIGroup
var Tab=(function(_super){
	function Tab(){
		Tab.__super.call(this);;
	}

	__class(Tab,'laya.ui.Tab',_super);
	var __proto=Tab.prototype;
	/**
	*@private
	*@inheritDoc
	*/
	__proto.createItem=function(skin,label){
		return new Button(skin,label);
	}

	return Tab;
})(UIGroup)


//class laya.ui.TextArea extends laya.ui.TextInput
var TextArea=(function(_super){
	function TextArea(text){
		/**@private */
		this._vScrollBar=null;
		/**@private */
		this._hScrollBar=null;
		(text===void 0)&& (text="");
		TextArea.__super.call(this,text);
		this.on("change",this,this._onTextChange);
	}

	__class(TextArea,'laya.ui.TextArea',_super);
	var __proto=TextArea.prototype;
	__proto._onTextChange=function(){
		this.callLater(this.changeScroll);
	}

	__proto.destroy=function(destroyChild){
		(destroyChild===void 0)&& (destroyChild=true);
		_super.prototype.destroy.call(this,destroyChild);
		this._vScrollBar && this._vScrollBar.destroy();
		this._hScrollBar && this._hScrollBar.destroy();
		this._vScrollBar=null;
		this._hScrollBar=null;
	}

	__proto.initialize=function(){
		this.width=180;
		this.height=150;
		this._tf.wordWrap=true;
		this.multiline=true;
	}

	__proto.onVBarChanged=function(e){
		if (this._tf.scrollY !=this._vScrollBar.value){
			this._tf.scrollY=this._vScrollBar.value;
		}
	}

	__proto.onHBarChanged=function(e){
		if (this._tf.scrollX !=this._hScrollBar.value){
			this._tf.scrollX=this._hScrollBar.value;
		}
	}

	__proto.changeScroll=function(){
		var vShow=this._vScrollBar && this._tf.maxScrollY > 0;
		var hShow=this._hScrollBar && this._tf.maxScrollX > 0;
		var showWidth=vShow ? this._width-this._vScrollBar.width :this._width;
		var showHeight=hShow ? this._height-this._hScrollBar.height :this._height;
		var padding=this._tf.padding || Styles.labelPadding;
		this._tf.width=showWidth;
		this._tf.height=showHeight;
		if (this._vScrollBar){
			this._vScrollBar.x=this._width-this._vScrollBar.width-padding[2];
			this._vScrollBar.y=padding[1];
			this._vScrollBar.height=this._height-(hShow ? this._hScrollBar.height :0)-padding[1]-padding[3];
			this._vScrollBar.scrollSize=1;
			this._vScrollBar.thumbPercent=showHeight / Math.max(this._tf.textHeight,showHeight);
			this._vScrollBar.setScroll(1,this._tf.maxScrollY,this._tf.scrollY);
			this._vScrollBar.visible=vShow;
		}
		if (this._hScrollBar){
			this._hScrollBar.x=padding[0];
			this._hScrollBar.y=this._height-this._hScrollBar.height-padding[3];
			this._hScrollBar.width=this._width-(vShow ? this._vScrollBar.width :0)-padding[0]-padding[2];
			this._hScrollBar.scrollSize=Math.max(showWidth *0.033,1);
			this._hScrollBar.thumbPercent=showWidth / Math.max(this._tf.textWidth,showWidth);
			this._hScrollBar.setScroll(0,this.maxScrollX,this.scrollX);
			this._hScrollBar.visible=hShow;
		}
	}

	/**滚动到某个位置*/
	__proto.scrollTo=function(y){
		this.commitMeasure();
		this._tf.scrollY=y;
	}

	/**垂直滚动值*/
	__getset(0,__proto,'scrollY',function(){
		return this._tf.scrollY;
	});

	__getset(0,__proto,'width',_super.prototype._$get_width,function(value){
		Laya.superSet(TextInput,this,'width',value);
		this.callLater(this.changeScroll);
	});

	/**水平滚动条实体*/
	__getset(0,__proto,'hScrollBar',function(){
		return this._hScrollBar;
	});

	__getset(0,__proto,'height',_super.prototype._$get_height,function(value){
		Laya.superSet(TextInput,this,'height',value);
		this.callLater(this.changeScroll);
	});

	/**水平滚动最大值*/
	__getset(0,__proto,'maxScrollX',function(){
		return this._tf.maxScrollX;
	});

	/**垂直滚动条皮肤*/
	__getset(0,__proto,'vScrollBarSkin',function(){
		return this._vScrollBar ? this._vScrollBar.skin :null;
		},function(value){
		if (this._vScrollBar==null){
			this.addChild(this._vScrollBar=new VScrollBar());
			this._vScrollBar.on("change",this,this.onVBarChanged);
			this._vScrollBar.target=this._tf;
			this.callLater(this.changeScroll);
		}
		this._vScrollBar.skin=value;
	});

	/**水平滚动条皮肤*/
	__getset(0,__proto,'hScrollBarSkin',function(){
		return this._hScrollBar ? this._hScrollBar.skin :null;
		},function(value){
		if (this._hScrollBar==null){
			this.addChild(this._hScrollBar=new HScrollBar());
			this._hScrollBar.on("change",this,this.onHBarChanged);
			this._hScrollBar.mouseWheelEnable=false;
			this._hScrollBar.target=this._tf;
			this.callLater(this.changeScroll);
		}
		this._hScrollBar.skin=value;
	});

	/**垂直滚动条实体*/
	__getset(0,__proto,'vScrollBar',function(){
		return this._vScrollBar;
	});

	/**垂直滚动最大值*/
	__getset(0,__proto,'maxScrollY',function(){
		return this._tf.maxScrollY;
	});

	/**水平滚动值*/
	__getset(0,__proto,'scrollX',function(){
		return this._tf.scrollX;
	});

	return TextArea;
})(TextInput)


	Laya.__init([View,GameConfig,EventDispatcher,LoaderManager,Timer,SceneUtils,LocalStorage,CallLater,GraphicAnimation]);
	/**LayaGameStart**/
	new Main();

})(window,document,Laya);

},{}]},{},[1]);
