package com.reynhart.FleshCannon
{
	import flash.text.engine.BreakOpportunity;
	import org.flixel.*;
	public class PatrolEnemy extends FlxSprite
	{
		private var level:FlxTilemap;
		private var tileSize:FlxPoint;
		private var player:Player;
		private var shotTicker:Number;
		private var shotDelay:Number;
		[Embed(source="../../../../assets/spaceman.png")] protected var ImgSpaceman:Class;
		public function PatrolEnemy(_x:int, _y:int, _facing:uint, _level:FlxTilemap, _player:Player)
		{
			super(_x, _y);
			shotDelay = 1;
			shotTicker = shotDelay;
			player = _player;
			facing = _facing;
			acceleration.y = 420;
			level = _level;
			tileSize = new FlxPoint(16, 16);
			loadGraphic(ImgSpaceman,true,true,8);
		}

		override public function update():void 
		{
			var tileX:int = x  / tileSize.x;
			var tileY:int = y / tileSize.y;
			switch(facing)
			{
				case(LEFT):
					velocity.x = -50;
					if (level.getTile(tileX, tileY + 1) == 0)
					{
						facing = RIGHT;
					}
					break;
				case(RIGHT):
					velocity.x = 50;
					if (level.getTile(tileX + 1, tileY + 1) == 0)
					{
						facing = LEFT;
					}
					break;
				default:
					break;
			}

			if (level.ray(new FlxPoint(x, y), new FlxPoint(player.x, player.y)))
			{
				velocity.x = 0;
				shotTicker -= FlxG.elapsed;
				if (shotTicker <= 0)
				{
					var shotAngle:Number = FlxU.getAngle(new FlxPoint(x, y), new FlxPoint(player.x, player.y)) - 90;
					var shotAngleR:Number = (Math.PI / 180) * shotAngle;
					var shotSpeed:FlxPoint = new FlxPoint(Math.cos(shotAngleR) * 200, Math.sin(shotAngleR) * 200);
					//(FlxG.state as PlayState).enemyBullets.add(new EnemyBullet(x, y, shotSpeed, shotAngle));
					shotTicker = shotDelay;
				}
			}
		}

		override public function hurt(Damage:Number):void
		{
			if(flickering)
				return;
			//FlxG.play(SndHurt);
			flicker(1.3);
			super.hurt(Damage);

			if( this.health == 0 )
			{
				kill();
			}
		}	

		override public function kill():void
		{
			if(!alive)
				return;
			super.kill();
			flicker(0);
			exists = true;
			visible = false;
			velocity.make();
			acceleration.make();
		}



	}

}

