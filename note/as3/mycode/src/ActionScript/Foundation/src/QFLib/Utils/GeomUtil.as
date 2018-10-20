////////////////////////////////////////////////////////////////////////////////
// Copyright (C) 2017 Shenzhen Qifun Network Co. Ltd. All Rights Reserved.
////////////////////////////////////////////////////////////////////////////////

package QFLib.Utils
{
	import flash.geom.Point;
	
	/**
	 * 几何学功能 
	 * @author lyman
	 * 
	 */	
	public class GeomUtil
	{
		/**
		 * 弧度转角度乘值 
		 */		
		public static const R_T_D:Number = 180 / Math.PI;
		/**
		 * 角度转弧度乘值 
		 */		
		public static const D_T_R:Number = Math.PI / 180;

		/**
		 * 弧度转角度 
		 * @param radians
		 * @return 
		 * 
		 */		
		public static function radiansToDegrees(radians:Number):Number
		{
			return radians * R_T_D;
		}

		/**
		 * 角度转弧度 
		 * @param degrees
		 * @return 
		 * 
		 */		
		public static function degreesToRadians(degrees:Number):Number
		{
			return degrees * D_T_R;
		}
		
		/**
		 * 两点间的角速度 
		 * @param p1
		 * @param p2
		 * @return 
		 * 
		 */		
		public static function angleSpeed(p1:Point,p2:Point):Point
		{
			var radians:Number = Math.atan2(p1.y - p2.y, p1.x - p2.x);
			return new Point(Math.cos(radians),Math.sin(radians));
		}
		
		/**
		 * 两点间的角度 
		 * @param p1
		 * @param p2
		 * @return 
		 * 
		 */		
		public static function pointAngle(p1:Point,p2:Point):Number
		{
			return Math.atan2(p1.y - p2.y, p1.x - p2.x) * R_T_D;
		}
		
		/**
		 * 两点间的弧度
		 * @param p1
		 * @param p2
		 * @return 
		 * 
		 */		
		public static function pointRadians(p1:Point,p2:Point):Number
		{
			return Math.atan2(p1.y - p2.y, p1.x - p2.x);
		}
		
		/**
		 * 角度转为角速度 
		 * @param angle
		 * @return 
		 * 
		 */		
		public static function angleToSpeed(angle:Number):Point
		{
			var radians:Number = angle * D_T_R;
			return new Point(Math.cos(radians),Math.sin(radians));
		}
		
		/**
		 * 弧度转为角速度 
		 * @param angle
		 * @return 
		 * 
		 */		
		public static function radiansToSpeed(radians:Number):Point
		{
			return new Point(Math.cos(radians),Math.sin(radians));
		}
		
		/**
		 * 获取一点周围圆形区域的一个点(正向运动基础算法)
		 * @param p 原始点
		 * @param angle 角度
		 * @param length 与当前点之间的长度
		 * @return 
		 * 
		 */		
		public static function getCirclePoint(p:Point,angle:Number,length:Number):Point
		{
			var radians:Number = angle * D_T_R;
			return p.add(new Point(Math.cos(radians)*length,Math.sin(radians)*length));
		}
	}
}

