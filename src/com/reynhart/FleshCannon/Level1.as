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
		
		public var level:FlxTilemap;
		public var barrels:FlxGroup;
		public var explosionHitBoxes:FlxGroup;
		
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
			
			width = level.width;
			height = level.height;
			
			add(level);
			
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
						barrels.add(new Barrel(tx, ty, explosionHitBox));	
						totalBarrels++;
					}
				}
					
			}
		}
	}
}
