package com.reynhart.FleshCannon {
	import org.flixel.FlxParticle;
	import org.flixel.FlxEmitter;
	import org.flixel.FlxG;
	import org.flixel.FlxPoint;
	import org.flixel.FlxSprite;

	import flash.display.Graphics;

	/**
	 * @author benje
	 */
	public class Barrel extends FlxSprite 
	{
		[Embed(source = '../../../../assets/singlestar.png')] private var starPNG:Class;
		
		//References
		protected var explosionHitBox:ExplosionHitBox;
		protected var explodeEmitter:FlxEmitter;
		
		public function Barrel(X:int, Y:int, _explosionHitBox:ExplosionHitBox, _explodeEmitter:FlxEmitter):void
		{
			super(X * 16, Y * 16, starPNG);
			
			//Store reference to explosionHitBox
			explosionHitBox = _explosionHitBox;
			explodeEmitter = _explodeEmitter;
			
			solid = true;
		}
		
				
		//Plays barrel explosion and passes impulse to player
		public function hitBarrel():void
		{
			solid = false;
			
			//Set corresponding explosionSprite as visible
			explosionHitBox.setActive();
			
			explodeEmitter.at(this);
			explodeEmitter.start(true, 1.5);
		}
		
		//Resets barrel state
		public function resetBarrelState():void
		{
			solid = true;
		}

		
	}
}
