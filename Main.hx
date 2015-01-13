package ;

#if desktop import sys.io.File; #end
import haxe.Json;
import openfl.display.DisplayObject;
import openfl.Assets;
import openfl.display.Sprite;
import openfl.geom.Matrix;

class Main
{
	public static function main() 
	{
		// TESTS for every generated matrix:
		// 1. Decompose matrix test: set transform.matrix of DisplayObject and compare x,y,scaleX,scaleY and rotation of DisplayObject
		// 2. Recompose test: get transform.matrix of DisplayObject and compare
		// 3. Set scaleX of DisplayObject to 1.0 and run test 2
		// 4. Set scaleY of DisplayObject to 1.0 and run test 2
		// 5. Set rotation of DisplayObject to 0.0 and run test 2
		// 6. Set x of DisplayObject to 0.0 and run test 2
		// 7. Set y of DisplayObject to 0.0 and run test 2
		
		#if desktop
		// On desktop target we create a file with test data - test.json with old and new version of lime.
		// Then you need to copy result in test_old.json or test_new.json to test with flash.
		
		var results : Array<Dynamic> = [];
		// Component is a component of matrix - a,b,c,d,tx or ty
		var N : Int = 2; // Number of component variations [-N, N]
		for (a in -N...(N + 1))
		{
			for (b in -N...(N + 1))
			{
				for (c in -N...(N + 1))
				{
					for (d in -N...(N + 1))
					{
						for (tx in -N...(N + 1))
						{
							for (ty in -N...(N + 1))
							{
								results.push(gen(a, b, c, d, tx, ty));
							}
						}
					}
				}
			}
		}
		// Gen some random matrices
		for (i in 0...5000)
		{
			results.push(gen(genFloat(), genFloat(), genFloat(), genFloat(), genFloat(), genFloat()));
		}
		File.saveContent("test.json", Json.stringify(results));
		openfl.Lib.exit();
		
		#else
		
		var result_old = test("test_old.json");
		var result_new = test("test_new.json");
		trace("Decompose test passed old(" + result_old.test1 + "%) new(" + result_new.test1 + "%)");
		trace("Recompose test passed old(" + result_old.test2 + "%) new(" + result_new.test2 + "%)");
		trace("Recompose test after 'scaleX = 1.0' passed old(" + result_old.test3 + "%) new(" + result_new.test3 + "%)");
		trace("Decompose test after 'scaleY = 1.0' passed old(" + result_old.test4 + "%) new(" + result_new.test4 + "%)");
		trace("Decompose test after 'rotation = 0.0' passed old(" + result_old.test5 + "%) new(" + result_new.test5 + "%)");
		trace("Decompose test after 'x = 0.0' passed old(" + result_old.test6 + "%) new(" + result_new.test6 + "%)");
		trace("Decompose test after 'y = 0.0' passed old(" + result_old.test7 + "%) new(" + result_new.test7 + "%)");
		
		#end
	}
	
	public static var displayObject : DisplayObject = new Sprite();
	public static function gen(a : Float, b : Float, c : Float, d : Float, tx : Float, ty : Float) : Dynamic
	{
		var m1 : Matrix = new Matrix(a, b, c, d, tx, ty);
		var result = { m1: { a : a, b : b, c : c, d : d, tx : tx, ty : ty } };
		// Decompose test generation
		displayObject.transform.matrix = m1;
		Reflect.setField(result, "x", displayObject.x);
		Reflect.setField(result, "y", displayObject.y);
		Reflect.setField(result, "scaleX", displayObject.scaleX);
		Reflect.setField(result, "scaleY", displayObject.scaleY);
		Reflect.setField(result, "rotation", displayObject.rotation);
		// Recompose tests generation
		#if !html5 displayObject.z = genFloat(); /* For update local matrix */ #end
		var m2 : Matrix = displayObject.transform.matrix;
		Reflect.setField(result, "m2", { a: m2.a, b : m2.b, c : m2.c, d : m2.d, tx : m2.tx, ty : m2.ty });
		displayObject.scaleX = 1.0;
		var m3 : Matrix = displayObject.transform.matrix;
		Reflect.setField(result, "m3", { a: m3.a, b : m3.b, c : m3.c, d : m3.d, tx : m3.tx, ty : m3.ty });
		displayObject.scaleY = 1.0;
		var m4 : Matrix = displayObject.transform.matrix;
		Reflect.setField(result, "m4", { a: m4.a, b : m4.b, c : m4.c, d : m4.d, tx : m4.tx, ty : m4.ty });
		displayObject.rotation = 0.0;
		var m5 : Matrix = displayObject.transform.matrix;
		Reflect.setField(result, "m5", { a: m5.a, b : m5.b, c : m5.c, d : m5.d, tx : m5.tx, ty : m5.ty });
		displayObject.x = 0.0;
		var m6 : Matrix = displayObject.transform.matrix;
		Reflect.setField(result, "m6", { a: m6.a, b : m6.b, c : m6.c, d : m6.d, tx : m6.tx, ty : m6.ty });
		displayObject.y = 0.0;
		var m7 : Matrix = displayObject.transform.matrix;
		Reflect.setField(result, "m7", { a: m7.a, b : m7.b, c : m7.c, d : m7.d, tx : m7.tx, ty : m7.ty });
		return result;
	}
	
	// filename - name of asset test file
	// result is procent of passed tests
	public static function test(filename : String) : Dynamic
	{
		var displayObject : DisplayObject = new Sprite();
		var tests : Array<Dynamic> = cast Json.parse(Assets.getText(filename));
		
		var passed1 : Int = 0;
		var passed2 : Int = 0;
		var passed3 : Int = 0;
		var passed4 : Int = 0;
		var passed5 : Int = 0;
		var passed6 : Int = 0;
		var passed7 : Int = 0;
		
		for (test in tests)
		{
			var m1 : Matrix = new Matrix(test.m1.a, test.m1.b, test.m1.c, test.m1.d, test.m1.tx, test.m1.ty);
			// Decompose test
			displayObject.transform.matrix = m1;
			if (equal(test.x, displayObject.x, 0.1) &&
				equal(test.y, displayObject.y, 0.1) &&
				equal(test.scaleX, displayObject.scaleX) &&
				equal(test.scaleY, displayObject.scaleY) &&
				equal(test.rotation, displayObject.rotation))	
				passed1++;
			
			// Recompose tests
			var m2 : Matrix = displayObject.transform.matrix;
			if (equal(test.m2.a, m2.a) &&
				equal(test.m2.b, m2.b) &&
				equal(test.m2.c, m2.c) &&
				equal(test.m2.d, m2.d) &&
				equal(test.m2.tx, m2.tx, 0.1) &&
				equal(test.m2.ty, m2.ty, 0.1))
				passed2++;
						
			displayObject.scaleX = 1.0;
			var m3 : Matrix = displayObject.transform.matrix;
			if (equal(test.m3.a, m3.a) &&
				equal(test.m3.b, m3.b) &&
				equal(test.m3.c, m3.c) &&
				equal(test.m3.d, m3.d) &&
				equal(test.m3.tx, m3.tx, 0.1) &&
				equal(test.m3.ty, m3.ty, 0.1))
				passed3++;
				
			displayObject.scaleY = 1.0;
			var m4 : Matrix = displayObject.transform.matrix;
			if (equal(test.m4.a, m4.a) &&
				equal(test.m4.b, m4.b) &&
				equal(test.m4.c, m4.c) &&
				equal(test.m4.d, m4.d) &&
				equal(test.m4.tx, m4.tx, 0.1) &&
				equal(test.m4.ty, m4.ty, 0.1))
				passed4++;
				
			displayObject.rotation = 0.0;
			var m5 : Matrix = displayObject.transform.matrix;
			if (equal(test.m5.a, m5.a) &&
				equal(test.m5.b, m5.b) &&
				equal(test.m5.c, m5.c) &&
				equal(test.m5.d, m5.d) &&
				equal(test.m5.tx, m5.tx, 0.1) &&
				equal(test.m5.ty, m5.ty, 0.1))
				passed5++;
				
			displayObject.x = 0.0;
			var m6 : Matrix = displayObject.transform.matrix;
			if (equal(test.m6.a, m6.a) &&
				equal(test.m6.b, m6.b) &&
				equal(test.m6.c, m6.c) &&
				equal(test.m6.d, m6.d) &&
				equal(test.m6.tx, m6.tx, 0.1) &&
				equal(test.m6.ty, m6.ty, 0.1))
				passed6++;
				
			displayObject.y = 0.0;
			var m7 : Matrix = displayObject.transform.matrix;
			if (equal(test.m7.a, m7.a) &&
				equal(test.m7.b, m7.b) &&
				equal(test.m7.c, m7.c) &&
				equal(test.m7.d, m7.d) &&
				equal(test.m7.tx, m7.tx, 0.1) &&
				equal(test.m7.ty, m7.ty, 0.1))
				passed7++;
		}
		return {
			test1: Math.floor(passed1 / (tests.length) * 100.0),
			test2: Math.floor(passed2 / (tests.length) * 100.0),
			test3: Math.floor(passed3 / (tests.length) * 100.0),
			test4: Math.floor(passed4 / (tests.length) * 100.0),
			test5: Math.floor(passed5 / (tests.length) * 100.0),
			test6: Math.floor(passed6 / (tests.length) * 100.0),
			test7: Math.floor(passed7 / (tests.length) * 100.0)
		}
	}
	
	private static var seed : Int = 12345;
	public static function genFloat() : Float
	{
		seed = seed * 0x343fd + 0x269ec3;
		return (((seed & 0x7fffffff) / 0x7fffffff) * 2.0 - 1.0) * 100.0;
	}
	
	public static function equal(value1 : Float, value2 : Float, eps : Float = 0.01) : Bool
	{
		return Math.abs(value1 - value2) < eps;
	}
}
