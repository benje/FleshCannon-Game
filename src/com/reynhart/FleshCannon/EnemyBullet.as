package com.reynhart.FleshCannon
{
	import org.flixel.*;
	public class EnemyBullet extends FlxSprite
	{
		[Embed(source="../../../../assets/bullet.png")] private var ImgBullet:Class;
		public function EnemyBullet(_x:int, _y:int, _velocity:FlxPoint, _angle:Number) 
		{
			super(_x, _y);
			velocity = _velocity;
			loadGraphic(ImgBullet,true);
			width = 6;
			height = 6;
			offset.x = 1;
			offset.y = 1;
		}
		
	}

}