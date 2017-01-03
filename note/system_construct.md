
---
title: 2016-11-7 结构
grammar_cjkRuby: true
grammar_mermaid: true
---
[TOC]

# 系统结构
## System
```mermaid!
sequenceDiagram
System->> NetHandler : Collect
System->> UIHandler : Collect
System->> Manager: Collect
System->> EventHandler: Collect
Note right of System : system is 模块
```

## UIHandler(MVC)
```mermaid!
sequenceDiagram
UIHandler->> Control: create and manager, bind to view
UIHandler->> View: Create and Manager
UIHandler->> DataCollection: listen DataUpdateEvent and setData in View
Note right of UIHandler : manager view and control, listenDataUpdate, set view Data
```
### Data(M)
```mermaid!
sequenceDiagram
DataCollection->> DataManager and otherData : use in View
DataManager ->> Data and Table : base data, has logic
Note right of DataManager : provide data and process data logic
```

### View结构(V)
```mermaid!
sequenceDiagram
View->> DataCollection: view UI by DataCollection 
View->> Control : dispatch UIEvent to Control
Note right of View: view UI by DataCollection and dispatch UIEvent to Control
```

### Control(C)
```mermaid!
sequenceDiagram
Control->> View: listen UIEvent, logic process
Note right of Control: listen UIEvent, logic process
```

## EventHandler
```mermaid!
sequenceDiagram
EventHandler->> System : provide event process
Note right of EventHandler : dispatchEvent
```

## NetHandler
```mermaid!
sequenceDiagram
NetHandler->> System : process Client <==> Server
Note right of NetHandler: dispatchEvent
```

## KeyboardHandler
```mermaid!
sequenceDiagram
KeyboardHandler->> System : process keyboard
Note right of KeyboardHandler: process keyboard
```
# System
* system
	* interface
		* ShowView
		* HideView
		* Enter
		* Exit
		* ListenEvent
		* UnlistenEvent
	* event
		* dispatchEvent
		* listenEvent
		* unlistenEvent
	* manager : system logic process
	* NetHandler: client <==> server
	* uiHandler : manager view
	* EventHandler : listen and dispatch event 
	* dataManager : store data and table, process data logic
	* visit interface by other system only. 
	
# Class
* UI
	* UIHandler : ViewManagerHandler
	* View
		* RootView : ViewBase implements IWindow
		* ChildView : ViewBase implements IWindow
	* ViewEvent : Event
	* Control : ControlBase
	* ViewComponent
		* IUIComponentMap : CUIComponentBase
		* Component : CUIComponentBase implements IUIComponentBase
		* UIEffectHandler implements IUIEffectHandler
* NetWorker
	* NetHandler :SystemHandler
* Logic
	* Manager : AbstractHandler
* Event
	* EventHandler : AbstractHandler
* Data
	* DataManager
	* Table
	* ObjectData
	* DataCollection

















## End
