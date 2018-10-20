package QFLib.Graphics.RenderCore.render.shader
{
	public class GA
	{
		[inline] static public function mov(dst:String, src:String):String
		{
			return "mov " + dst + ", " + src + "\n";
		}
		
		[inline] static public function add(dst:String, src0:String, src1:String):String
		{
			return "add " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function adds(src0:String, src1:String):String
		{
			return "add " + src0  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function sub(dst:String, src0:String, src1:String):String
		{
			return "sub " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function subs(src0:String, src1:String):String
		{
			return "sub " + src0  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function mul(dst:String, src0:String, src1:String):String
		{
			return "mul " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function muls(src0:String, src1:String):String
		{
			return "mul " + src0  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function div(dst:String, src0:String, src1:String):String
		{
			return "div " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function divs(src0:String, src1:String):String
		{
			return "div " + src0  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function dot3(dst:String, src0:String, src1:String):String
		{
			return "dp3 " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function dot3s(src0:String, src1:String):String
		{
			return "dp3 " + src0  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function dot4(dst:String, src0:String, src1:String):String
		{
			return "dp4 " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function dot4s(src0:String, src1:String):String
		{
			return "dp4 " + src0  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function crs(dst:String, src0:String, src1:String):String
		{
			return "crs " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function crss(src0:String, src1:String):String
		{
			return "crs " + src0  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function m44(dst:String, src0:String, src1:String):String
		{
			return "m44 " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function m33(dst:String, src0:String, src1:String):String
		{
			return "m33 " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function m34(dst:String, src0:String, src1:String):String
		{
			return "m34 " + dst  + ", "
			+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function sin(dst:String, src:String):String
		{
			return "sin " + dst + ", " + src + "\n";
		}
		
		
		[inline] static public function sins(src:String):String
		{
			return "sin " + src + ", " + src + "\n";
		}
		
		[inline] static public function cos(dst:String, src:String):String
		{
			return "cos " + dst + ", " + src + "\n";
		}
		
		[inline] static public function coss(src:String):String
		{
			return "cos " + src + ", " + src + "\n";
		}
		
		[inline] static public function rcp(dst:String, src:String):String
		{
			return "rcp " + dst + ", " + src  + "\n";
		}
		
		[inline] static public function rcps(src:String):String
		{
			return "rcp " + src + ", " + src  + "\n";
		}
		
		[inline] static public function kil(src:String):String
		{
			return "kil "+ src + "\n";
		}
		
		[inline] static public function tex(dst:String, uv:String, index:int):String
		{
			return "tex " + dst +", "
			+ uv + ", fs" + index +"\n";
		}
		
		[inline] static public function max(dst:String, src0:String, src1:String):String
		{
			return "max " + dst  + ", "
				+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function maxs(src0:String, src1:String):String
		{
			return "max " + src0  + ", "
				+ src0 + ", " + src1 + "\n";
		}

		[inline] static public function min(dst:String, src0:String, src1:String):String
		{
			return "min " + dst  + ", "
					+ src0 + ", " + src1 + "\n";
		}

		[inline] static public function mins(src0:String, src1:String):String
		{
			return "min " + src0  + ", "
					+ src0 + ", " + src1 + "\n";
		}
		
		[inline] static public function frc(dst:String, src:String):String
		{
			return "frc " + dst  + ", "
				+ src + "\n";
		}
		
		[inline] static public function grid(row:String, col:String, src:String, grid:String):String
		{
//			return	"div " + row + ", " + src + ", " + grid + "\n" +	//除法获得行
//					"frc " + col + ", " + row + "\n" +					//去掉小数部分
//					"sub " + row + ", " + row + ", " + col + "\n" +
//					"mul " + col + ", " + row + ", " + grid + "\n" +	//计算取模	
//					"sub " + col + ", " + src + ", " + col + "\n";
			
			return GA.div(row, src, grid) +
					GA.frc(col, row) +
					GA.subs(row, col) +
					GA.mul(col, row, grid) +
					GA.sub(col, src, col);
		}
		
		[inline] static public function sat(dst:String, src:String):String
		{
			return "sat " + dst + ", "
				+ src + "\n";
		}

		[inline] static public function sge(dst:String, src0:String, src1:String):String
		{
			return "sge " + dst + ", " + src0 + ", " +
					src1 + "\n";
		}

		[inline] static public function slt(dst:String, src0:String, src1:String):String
		{
			return "slt " + dst + ", " + src0 + ", " +
					src1 + "\n";
		}

		[inline] static public function abs(dst:String, src:String):String
		{
			return "abs " + dst + ", " + src + "\n";
		}

		[inline] static public function abss(src:String):String
		{
			return "abs " + src + ", " + src + "\n";
		}

		[inline] static public function neg(dst:String, src:String):String
		{
			return "neg " + dst + ", " + src + "\n";
		}

		[inline] static public function negs(src:String):String
		{
			return "neg " + src + ", " + src + "\n";
		}

		[inline] static public const outColor:String = "oc";
		
		[inline] static public const outPos:String = "op";
	}
}