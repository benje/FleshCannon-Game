package com.reynhart.FleshCannon 
{
	import org.flixel.plugin.photonstorm.FlxDelay;
	import org.flixel.FlxSprite;

	/**
	 * @author administrator
	 */
	public class ExplosionHitBox extends FlxSprite 
	{
		[Embed(source='../../../../assets/explosion.png')] private var explosionPNG:Class;
		
		private var isFading:Boolean = false;
		private var fadeDuration:int = 1000;
		private var fadeTimer:FlxDelay = new FlxDelay( fadeDuration );
		
		public function ExplosionHitBox(X : Number = 0, Y : Number = 0) 
		{
			super((X * 16)-8, (Y * 16)-8, explosionPNG);
			
			this.solid = false;
			this.visible = false;
		}
		
		//Sets this visible and solid
		public function setActive():void
		{
			this.solid = true;
			this.visible = true;
			
			//Start fadeTimer
			fadeTimer.start();
			
			this.flicker( Number(fadeDuration) );
			
			//disFading = true;
		}
		
		//When completely faded out - reset state
		private function setInactive():void
		{
			this.visible = false;
			this.solid = false;
			this.alpha = 1;
		}
		
		//Update function override
		override public function update():void
		{
			//If timer has elapsed then call setInactive
			if (fadeTimer.hasExpired)
			{
				setInactive();
			}
			
		}
//			//If isFading is toggled then start dropping alpha
//			if( isFading )
//			{
//				//Check alpha reached 0 - then disable
//				if (this.alpha == 0)
//				{
//					isFading = false;
//					setInactive();
//				}
//				
//				this.alpha = this.alpha - 0.015;	
//			}
//		}
		
		
	}
}
