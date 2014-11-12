package
{
	import com.myapp.Game;
	
	import flash.display.Sprite;
	
	import starling.core.Starling;
	import starling.events.Event;
	
	[SWF(width="600", height="400", backgroundColor="0xffffff", frameRate="60")]
	public class ParticlesWithNape extends Sprite
	{
		private var _starling:Starling;
		
		public function ParticlesWithNape()
		{
			_starling = new Starling(Game, stage);
			_starling.showStats = true;
			_starling.antiAliasing = 1;
			_starling.addEventListener(Event.CONTEXT3D_CREATE, created);
			_starling.start();
		}
		
		private function created(e:Event):void
		{

			
		}
	}
}