package com.reynhart.FleshCannon
{
	import com.greensock.TweenLite;

	import org.flixel.*;

	public class Player extends FlxSprite
	{
		[Embed(source="data/spaceman.png")] protected var ImgSpaceman:Class;


		protected var _jumpPower:int;
		protected var _aim:uint;
		protected var _bullets:FlxGroup;
		protected var _restart:Number;
		protected var _shootTimer:Number;
		protected var _gibs:FlxEmitter;
		protected var _clones:Array = new Array();
		protected var _teleporting:Boolean = false;

		public function Player( X:int,Y:int,Bullets:FlxGroup, Gibs:FlxEmitter )
		{
			super(X,Y);
			loadGraphic(ImgSpaceman,true,true,8);
			_restart = 0;

			//basic player physics
			var runSpeed:uint = 80;
			drag.x = runSpeed*8;
			acceleration.y = 420;
			_jumpPower = 200;
			maxVelocity.x = runSpeed;
			maxVelocity.y = _jumpPower;

			//animations
			addAnimation("idle", [0]);
			addAnimation("run", [1, 2, 3, 0], 12);
			addAnimation("jump", [4]);
			addAnimation("idle_up", [5]);
			addAnimation("run_up", [6, 7, 8, 5], 12);
			addAnimation("jump_up", [9]);
			addAnimation("jump_down", [10]);

			_bullets = Bullets;
			_gibs = Gibs;
		}


		override public function destroy():void
		{
			super.destroy();
			_bullets = null;
			_gibs = null;
		}

		override public function update():void
		{
			//game restart timer
			if(!alive)
			{
				_restart += FlxG.elapsed;
				if(_restart > 2)
					FlxG.resetState();
				return;
			}

			//make a little noise if you just touched the floor
			if(justTouched(FLOOR) && (velocity.y > 50)){
				//FlxG.play(SndLand);
			}

			//MOVEMENT
			acceleration.x = 0;

			if(FlxG.keys.LEFT)
			{
				facing = LEFT;
				acceleration.x -= drag.x;
			}
			else if(FlxG.keys.RIGHT)
			{
				facing = RIGHT;
				acceleration.x += drag.x;
			}
			if(FlxG.keys.justPressed("X") && !velocity.y || FlxG.keys.justPressed("SPACE") && !velocity.y)
			{
				velocity.y = -_jumpPower;
					//FlxG.play(SndJump);
			}

			//AIMING
			if(FlxG.keys.UP)
				_aim = UP;
			else if(FlxG.keys.DOWN && velocity.y)
				_aim = DOWN;
			else
				_aim = facing;

			//ANIMATION
			if(velocity.y != 0)
			{
				if(_aim == UP) play("jump_up");
				else if(_aim == DOWN) play("jump_down");
				else play("jump");
			}
			else if(velocity.x == 0)
			{
				if(_aim == UP) play("idle_up");
				else play("idle");
			}
			else
			{
				if(_aim == UP) play("run_up");
				else play("run");
			}

			//Checking bounds is within world
			if( x > FlxG.width - this.width )
			{
				this.x = FlxG.width - this.width
				this.velocity.x = 0;
			} 
			else if ( x < 0 )
			{
				this.x = 0;
				this.velocity.x = 0;
			}


			//Testing FleshCannon shoot key V
			if(FlxG.keys.justPressed("V"))
			{
				//If not already teleporting then shoot fleshcannon
				if(!_teleporting)
				{
					fleshCannonShoot();
				}
			}

			//SHOOTING
			if(FlxG.keys.justPressed("C"))
			{
				var bullet:Bullet = new Bullet( getMidpoint().x, getMidpoint().y );
				//(FlxG.state as PlayState)._bullets.add( bullet );
				(FlxG.state as PlayState).add( bullet );
				bullet.shoot( getMidpoint(), _aim);
			}

			//Fading out clones from array & removing them.
			var markArray:Array = new Array();
			//Iterate clones array and fade down
			for (var i:Number = 0; i < this._clones.length; i++ )
			{
				_clones[i].alpha -= 0.01;

				if(_clones[i].alpha == 0)
				{
					_clones[i].alpha = 0
					markArray[i] = true;
				}
			}
			//Remove marked objects
			for ( var j:Number = 0; j < markArray.length; j++)
			{
				if(markArray[j])
				{
					_clones.splice( j, 1 );
				}
			}
		}

		//On fleshCannon shoot
		private function fleshCannonShoot():void
		{
			var fleshBullet:FleshBullet = new FleshBullet( getMidpoint().x, getMidpoint().y );
			(FlxG.state as PlayState).add( fleshBullet );
			fleshBullet.shoot( getMidpoint(), _aim);
			FlxG.camera.follow( fleshBullet );

			//Set player invisible
			visible = false;
			_teleporting = true;

			//Listen for bullet to stop in new location
			fleshBullet.bulletStopped.addOnce( teleportPlayer );

			createEmptyPlayerSkin();
		}

		//Create player skin - fades away when you shoot flesh bullet
		private function createEmptyPlayerSkin():void
		{
			var playerClone:FlxSprite = new FlxSprite();
			playerClone.loadGraphic( ImgSpaceman,true,true,8 );
			(FlxG.state as PlayState).add( playerClone );
			playerClone.x = x;
			playerClone.y = y;
			_clones.push( playerClone );
		}

		//Teleport player makes player appear at bullet destination
		private function teleportPlayer( destX:Number, destY:Number ):void
		{	
			_teleporting = false;

			//Reset camera
			FlxG.camera.follow( this );

			x = destX;
			y = destY;
			visible = true;
			flicker(0.5);

			if(_gibs != null)
			{
				_gibs.at(this);
					//_gibs.start(true,5,0,50);
			}

			FlxG.camera.flash(0xffffff,0.35);
		}



		override public function hurt(Damage:Number):void
		{
			Damage = 0;
			//if(flickering)
			//	return;
			//FlxG.play(SndHurt);
			flicker(1.3);
			if(FlxG.score > 1000) FlxG.score -= 1000;
			if(velocity.x > 0)
				velocity.x = -maxVelocity.x;
			else
				velocity.x = maxVelocity.x;
			super.hurt(Damage);
		}	

		override public function kill():void
		{
			if(!alive)
				return;
			super.kill();
			//flicker(0);
			exists = true;
			visible = false;
			velocity.make();
			acceleration.make();
			FlxG.camera.shake(0.005,0.35);
			FlxG.camera.flash(0xffd8eba2,0.35);
		}

	}
}

