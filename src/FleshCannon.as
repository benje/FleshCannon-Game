package
{
	import org.flixel.*;
	import com.reynhart.FleshCannon.MenuState;
	[SWF(width="800", height="600", frameRate="30", backgroundColor="#000000")]
	[Frame(factoryClass="Preloader")]

	public class FleshCannon extends FlxGame
	{
		public function FleshCannon()
		{
			super(400,300,MenuState,2);
			forceDebugger = true;
		}
	}
}

