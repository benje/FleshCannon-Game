package com.reynhart.FleshCannon {
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;
	import flash.display.Graphics;

	/**
	 * @author benje
	 */
	public class Barrel extends FlxSprite 
	{
		[Embed(source = '../../../../assets/star.png')] private var starPNG:Class;
		
		public var explosionRadius:int = 25;
		public var explosionSprite:FlxSprite;
		
		public function Barrel(X:int, Y:int):void
		{
			super(X * 16, Y * 16, starPNG);
			
			solid = true;
		}
		
				
		//Plays barrel explosion and passes impulse to player
		public function hitBarrel():void
		{
			trace("hitBarrel on " + this);
			solid = false;
		}
		
		//Create explosion sprite
		public function createExplosion(X:int, Y:int):void
		{
			//Create explodeSprite
			explosionSprite = new FlxSprite();
			drawCircle(explosionSprite, new FlxPoint(explosionRadius, explosionRadius),explosionRadius, 0xff33ff33, 1, 0x4433ff33);
			
			(FlxG.state as PlayState).add( explosionSprite );
		}

		
		/**
		 * Draw a circle to a sprite.
		 *
		 * @param   Sprite          The FlxSprite to draw to
		 * @param   Center          x,y coordinates of the circle's center
		 * @param   Radius          Radius in pixels
		 * @param   LineColor       Outline color
		 * @param   LineThickness   Outline thickness
		 * @param   FillColor       Fill color
		 */
		public function drawCircle(Sprite:FlxSprite, Center:FlxPoint, Radius:Number = 30, LineColor:uint = 0xffffffff, LineThickness:uint = 1, FillColor:uint = 0xffffffff):void {
		 
		    var gfx:Graphics = FlxG.flashGfx;
		    gfx.clear();
		 
		    // Line alpha
		    var alphaComponent:Number = Number((LineColor >> 24) & 0xFF) / 255;
		    if(alphaComponent <= 0)
		        alphaComponent = 1;
		 
		    gfx.lineStyle(LineThickness, LineColor, alphaComponent);
		 
		    // Fill alpha
		    alphaComponent = Number((FillColor >> 24) & 0xFF) / 255;
		    if(alphaComponent <= 0)
		        alphaComponent = 1;
		 
		    gfx.beginFill(FillColor & 0x00ffffff, alphaComponent);
		 
		    gfx.drawCircle(Center.x, Center.y, Radius);
		 
		    gfx.endFill();
		 
		    Sprite.pixels.draw(FlxG.flashGfxSprite);
		    Sprite.dirty = true;
		}
		

		
		
	}
}
