package com.reynhart.FleshCannon
{
	import org.flixel.*;
	import org.osflash.signals.Signal;

	public class FleshBullet extends FlxSprite
	{
		[Embed(source="data/flesh-bullet.png")] private var ImgBullet:Class;
		[Embed(source="data/shoot.mp3")] private var SndShoot:Class;

		public var speed:Number;
		public var bulletStopped:Signal = new Signal( Number, Number );

		protected var _direction:int;

		public function FleshBullet(X:Number=0, Y:Number=0)
		{
			super();
			loadGraphic(ImgBullet,true);
			width = 6;
			height = 6;
			offset.x = 1;
			offset.y = 1;
			drag.x = 6;
			drag.y = 10;

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

					//Check velocity is above 0 else stop (not reverse)
					if(velocity.y < 0)
					{
						velocity.y += drag.y;
					} else {
						velocity.y = 0;
						onDestinationArrived();
					}

					break;

				case DOWN:
					play("down");
					velocity.y = speed;
					break;

				case LEFT:
					//Check velocity is above 0 else stop (not reverse)
					if(velocity.x < 0)
					{
						velocity.x += drag.x;
					} else {
						velocity.x = 0;
						onDestinationArrived();
					}
					break;

				case RIGHT:
					//Check velocity is above 0 else stop (not reverse)
					if(velocity.x > 0)
					{
						velocity.x -= drag.x;
					} else {
						velocity.x = 0;
						onDestinationArrived();
					}
					break

				default:
					break;
			}

		}

		private function onDestinationArrived():void
		{
			//When stopped dispatch signal with co-ordinates
			bulletStopped.dispatch( x, y );

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

		public function shoot(Location:FlxPoint, Aim:uint):void
		{
			_direction = Aim;

			FlxG.play(SndShoot);
			super.reset(Location.x-width/2,Location.y-height/2);
			//solid = true;
			switch(Aim)
			{
				case UP:
					play("up");
					velocity.y = -speed;
					break;
				case DOWN:
					play("down");
					velocity.y = speed;
					break;
				case LEFT:
					play("left");
					velocity.x = -speed;
					break;
				case RIGHT:
					play("right");
					velocity.x = speed;
					break;
				default:
					break;
			}
		}


	}
}

