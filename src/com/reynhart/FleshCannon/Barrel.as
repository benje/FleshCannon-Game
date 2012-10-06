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
		
		public var explosionRadius:int = 25;
		public var explosionSprite:ExplosionHitBox;
		
		//Explosion particles
		protected var particle:FlxParticle;
		protected var explodeEmitter:FlxEmitter;
		
		public function Barrel(X:int, Y:int, _explosionSprite:ExplosionHitBox):void
		{
			super(X * 16, Y * 16, starPNG);
			
			explosionSprite = _explosionSprite;
			
			solid = true;
			
			//Create explosion emitter & add to PlayState
			explodeEmitter = createParticles(x, y);
			(FlxG.state as PlayState).add(explodeEmitter);
		}
		
				
		//Plays barrel explosion and passes impulse to player
		public function hitBarrel():void
		{
			trace("hitBarrel on " + this);
			solid = false;
			
			//Set corresponding explosionSprite as visible
			explosionSprite.setActive();
			
			explodeEmitter.start(true, 1.5);
		}
		
		//Resets barrel state
		public function resetBarrelState():void
		{
			solid = true;
		}
		
		
		//Creates a particle emitter & returns FlxEmitter
		private function createParticles(X:Number, Y:Number):FlxEmitter 
		{
			var part_emitter:FlxEmitter =  new FlxEmitter(X, Y, 100); 
           	part_emitter.setXSpeed(-80,80);
			part_emitter.setYSpeed(-80,0);
			part_emitter.setRotation(-720,-720);
			part_emitter.gravity = 200;
			part_emitter.bounce = 0.5;
			 
			//Now it's almost ready to use, but first we need to give it some pixels to spit out!
			//Lets fill the emitter with some white pixels
			for (var i:int = 0; i < part_emitter.maxSize; i++) {
				particle = new FlxParticle();
				particle.makeGraphic(2, 2, 0xFFFFFFFF);
				particle.visible = false; //Make sure the particle doesn't show up at (0, 0)
				part_emitter.add(particle);
//				particle = new FlxParticle();
//				particle.makeGraphic(1, 1, 0xFFFFFFFF);
//				particle.visible = false;
//				part_emitter.add(particle);
			}
			
			return part_emitter;
        }   
		
		
	}
}
