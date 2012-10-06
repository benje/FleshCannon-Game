package com.reynhart.FleshCannon
{
	import org.flixel.*;
	import org.osflash.signals.Signal;

	public class FleshBullet extends FlxSprite
	{
		[Embed(source="../../../../assets/flesh-bullet.png")] private var ImgBullet:Class;
		[Embed(source="../../../../assets/sounds/fc-cannon-shoot2.mp3")] protected var CannonShoot:Class;

		public var speed:Number;
		protected var shotVel:Number = 400;
		public var bulletStopped:Signal = new Signal( Number, Number );

		protected var _direction:String;

		public function FleshBullet(X:Number=0, Y:Number=0)
		{
			super();
			loadGraphic(ImgBullet,true);
			width = 6;
			height = 6;
			offset.x = 1;
			offset.y = 1;
			drag.x = 600;
			drag.y = 600;

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

			//Check worldbounds - if bullet leaves worldbounds replace it
			//Depending on bullet direction slow down
			switch(_direction)
			{
				case UP:
					play("up");
					break;
				case DOWN:
					play("down");
					break;
				case LEFT:
					play("left");
					break;
				case RIGHT:
					play("right");
					break;
				default:
					break;
			}
			if (velocity.y == 0 && velocity.x == 0)
			{
				onDestinationArrived();
			}
		}

		private function onDestinationArrived():void
		{
			//When stopped dispatch signal with co-ordinates
			bulletStopped.dispatch( x, y, this );

			kill();
		}

		override public function kill():void
		{
			if(!alive)
				return;
			velocity.x = 0;
			velocity.y = 0;
			if(onScreen())
				//FlxG.play(SndHit);
				alive = false;
			solid = false;
			play("poof");
		}

		public function shoot(Location:FlxPoint, aimHeading:String ):void
		{
			_direction = aimHeading;

			//Play Sound
			FlxG.play( CannonShoot, 1 );

			super.reset(Location.x-width/2,Location.y-height/2);

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

