package com.reynhart.FleshCannon
{
	import org.flixel.*;

	public class Bullet extends FlxSprite
	{
		[Embed(source="data/bullet.png")] private var ImgBullet:Class;
		[Embed(source="data/shoot.mp3")] private var SndShoot:Class;

		public var speed:Number;
		protected var shotVel:Number = 400;

		public function Bullet(X:Number=0, Y:Number=0)
		{
			super();
			loadGraphic(ImgBullet,true);
			width = 6;
			height = 6;
			offset.x = 1;
			offset.y = 1;
			//drag.x = drag.y = 100;


			addAnimation("up",[0]);
			addAnimation("down",[1]);
			addAnimation("left",[2]);
			addAnimation("right",[3]);
			addAnimation("poof",[4, 5, 6, 7], 50, false);

			speed = 360;
		}

		override public function update():void
		{
			if(!alive)
			{
				if(finished)
					exists = false;
			}
			else if(touching)
				kill();

			if(!onScreen())
			{
				kill();
			}
		}

//		override public function kill():void
//		{
//			if(!alive)
//				return;
//			velocity.x = 0;
//			velocity.y = 0;
//			if(onScreen())
//				//FlxG.play(SndHit);
//				alive = false;
//			solid = false;
//			play("poof");
//		}

		public function shoot(Location:FlxPoint, aimHeading:String ):void
		{
			//FlxG.log( aimHeading );
			FlxG.play(SndShoot);
			super.reset(Location.x-width/2,Location.y-height/2);
			//solid = true;

			var aimAngle:Number;
			switch( aimHeading )
			{
				case "N":
					play("up");
					aimAngle = -90;
					break;
				case "NE":
					play("right");
					aimAngle = -45;
					break;
				case "E":
					play("right");
					aimAngle = 0;
					break;
				case "SE":
					play("right");
					aimAngle = 45;
					break;
				case "S":
					play("down");
					aimAngle = 90;
					break;
				case "SW":
					play("left");
					aimAngle = 135;
					break;
				case "W":
					play("left");
					aimAngle = 180;
					break;
				case "NW":
					play("left");
					aimAngle = -135;
					break;
				default:
					break;
			}
			var angleAsRadians:Number = (Math.PI / 180) * aimAngle;
			velocity.x = Math.cos( angleAsRadians ) * shotVel;
			velocity.y = Math.sin( angleAsRadians ) * shotVel;

		}


	}
}

