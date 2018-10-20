// =================================================================================================
//
//	Qifun Framework
//	Copyright 2015 Qifun. All Rights Reserved.
//
//	This program is free software. You can redistribute and/or modify it
//	in accordance with the terms of the accompanying license agreement.
//
// =================================================================================================
package QFLib.Graphics.RenderCore.starling.utils
{
	import flash.system.Capabilities;

	public class Version
	{
		private static var sVersionNumber:Vector.<int>;
		private static var sIsBaselineVersion:Boolean;
		private static var sFlashPlayerVersion:String;
		
		private static var sHasCheckedBuild:Boolean = false;
		private static var sIsDebugBuildMode:Boolean;

		public static function getVersionNumber():Vector.<int>
		{
			if (sVersionNumber == null)
			{
				var versionInfo:String = Capabilities.version;
				var versionNumString:String = versionInfo.split(" ")[1];
				var versionNumArray:Array = versionNumString.split(",");

				sVersionNumber = new Vector.<int>();
				for each (var v:Object in versionNumArray)
				{
					sVersionNumber.push(int(v));
				}
			}

			return sVersionNumber;
		}

		public static function flashPlayerVersion():String{
			if(sFlashPlayerVersion == null){
				var version:Vector.<int> = Version.getVersionNumber();
				
				sFlashPlayerVersion = version[0] + "." + version[1] + (isDebugPlayer() ? "-debug" : "-release");
			}
			
			return sFlashPlayerVersion;
		}
		
		public static function isBaselineVersion():Boolean
		{
			if (sVersionNumber == null)
			{
				var version:Vector.<int> = Version.getVersionNumber();

				// 小于等于11.7的版本使用baseline模式
				if (version[0] <= 11)
				{
					sIsBaselineVersion = true;
				}
				else
				{
					sIsBaselineVersion = false;
				}
			}

			return sIsBaselineVersion;
		}
		
		/**
		 * Returns true if the user is running the app on a Debug Flash Player.
		 * Uses the Capabilities class
		 **/
		public static function isDebugPlayer() : Boolean
		{
			return Capabilities.isDebugger;
		}
		
		/**
		 * Returns true if the swf is built in debug mode
		 **/
		public static function isDebugBuild() : Boolean
		{
			if (!sHasCheckedBuild)
			{
				var stackTrace:String = new Error().getStackTrace();
				sIsDebugBuildMode = (stackTrace && stackTrace.search(/:[0-9]+]$/m) > -1);
				
				sHasCheckedBuild = true;
			}
			
			return sIsDebugBuildMode;
		}
		
		/**
		 * Returns true if the swf is built in release mode
		 **/
		public static function isReleaseBuild() : Boolean
		{
			return !isDebugBuild();
		}
	}
}
