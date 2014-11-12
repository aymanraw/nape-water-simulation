package com.myapp
{
	import flash.geom.Point;
	
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.space.Space;
	
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.filters.ThresholdFilter;
	import starling.textures.RenderTexture;
	
	public class WaterDrop extends Sprite
	{
		[Embed(source="../assets/Blue.png")]
		private var Blue:Class;
		
		private var _space:Space;
		private var _body:Body;
		private var _pos:Vec2;
		
		private var _threshold:ThresholdFilter;
		private var _renderTexture:RenderTexture;
		
		private var img:Image;
		private var img2:Image;
		
		public function WaterDrop(space:Space, pos:Vec2)
		{
			_space = space;
			_pos = pos;
			addEventListener(Event.ADDED_TO_STAGE, initilaized);	
			
		}
		
		private function initilaized(e:Event):void
		{
			img = Image.fromBitmap(new Blue());
			
			_renderTexture = new RenderTexture(img.width, img.height, true);
			_renderTexture.draw(img);
			
			var renderTextureImage:Image = new Image(_renderTexture);
			renderTextureImage.pivotX = renderTextureImage.width/2;
			renderTextureImage.pivotY = renderTextureImage.height/2;
			
			
			body = new Body(BodyType.DYNAMIC);
			body.shapes.add(new Circle(20));
			body.position = _pos;
			body.space = _space;
			body.userData.graphic = renderTextureImage;
			
			
			addChild(renderTextureImage);
			
			_threshold = new ThresholdFilter(0.5);
			renderTextureImage.filter = _threshold;
			
			
			addEventListener(Event.ENTER_FRAME, loop2);
			
				
		}
		
		private function loop2(e:Event):void
		{
			_renderTexture.clear();
			_renderTexture.draw(img);
			
		}		
		
		
		
		
		public function get body():Body
		{
			return _body;
		}
		
		public function set body(value:Body):void
		{
			_body = value;
		}

	}
}