namespace gameframework {
export namespace framework {
/**
 * ...
 * @author auto
 */
export interface ILifeCycle {
	// function onAwark() : void;
	// function onStart() : void;
	// function onUpdate(deltaTime:number) : void;
	// function onFixedUpdate(fixTime:number) : void;
	// function onDestroy() : void;

	awake() : void ;
	start() : boolean ;

	// function update(deltaTime:number) : void ;
	// function fixUpdate(fixTime:number) : void ;
	destroy() : void;
}
}
}	
