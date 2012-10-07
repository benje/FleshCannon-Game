package com.reynhart.FleshCannon 
{
	import org.flixel.*;

	/**
	 * @author benje
	 */
	public class Level1 extends FlxGroup 
	{
		[Embed(source="../../../../assets/levels/mapCSV_Group1_Map1.csv", mimeType="application/octet-stream")] public var CSV_Map1:Class;
		[Embed(source="../../../../assets/levels/mapCSV_Group1_Barrels.csv", mimeType="application/octet-stream")] public var barrelsCSV:Class;
		[Embed(source="../../../../assets/tiles.png")] public var Img_Map1:Class;
		[Embed(source="../../../../assets/star.png")] public var starPNG:Class;
		[Embed(source="../../../../assets/gibs.png")] private var ImgGibs:Class;
		
		public var level:FlxTilemap;
		public var barrels:FlxGroup;
		public var explosionHitBoxes:FlxGroup;
		protected var _littleGibs:FlxEmitter;
		
		public var width:int;
		public var height:int;
		public var totalBarrels:int;
		
		public function Level1() 
		{
			super();
			
			FlxG.bgColor = 0xffcccccc;
			
			//Create the Level using FlxTilemap from embedded csv
			level = new FlxTilemap();
			level.loadMap( new CSV_Map1, Img_Map1, 16, 16 );
			
			//	Makes these tiles as allowed to be jumped UP through (but collide at all other angles)
			level.setTileProperties(106, FlxObject.UP, null, null, 4);
			
			width = level.width;
			height = level.height;
			
			add(level);
			
			_littleGibs = new FlxEmitter();
			_littleGibs.setXSpeed(-150,150);
			_littleGibs.setYSpeed(-200,0);
			_littleGibs.setRotation(-720,-720);
			_littleGibs.gravity = 350;
			_littleGibs.bounce = 0.5;
			_littleGibs.makeParticles(ImgGibs,10,10,true,0.5);
			add(_littleGibs);
			
			//TODO: FIX PERFORMANCE PROBLEM WHEN ADD BARRELS
			parseBarrels();
		}
		
		
		private function parseBarrels():void
		{
			var barrelsMap:FlxTilemap = new FlxTilemap();
			
			barrelsMap.loadMap(new barrelsCSV, starPNG, 16, 16);
			
			barrels = new FlxGroup();
			explosionHitBoxes = new FlxGroup();
			
			for (var ty:int = 0; ty < barrelsMap.heightInTiles; ty++)
			{
				for (var tx:int = 0; tx < barrelsMap.widthInTiles; tx++)
				{
					if(barrelsMap.getTile(tx, ty) == 1)
					{
						//Create hittest radius sprite
						var explosionHitBox:ExplosionHitBox = new ExplosionHitBox(tx, ty);
						explosionHitBoxes.add( explosionHitBox );
					
						//Add barrels
						barrels.add(new Barrel(tx, ty, explosionHitBox, _littleGibs));	
						totalBarrels++;
					}
				}
					
			}
		}
	}
}
