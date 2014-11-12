package com.myapp
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.geom.Point;
	
	import nape.constraint.PivotJoint;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.KeyboardEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.filters.ThresholdFilter;
	import starling.textures.Texture;
	
	public class Game extends Sprite
	{
		private var _debug:BitmapDebug;
		private var _space:Space;
		
		[Embed(source="../assets/Blue.png")]
		private var Blue:Class;
		
		private var _threshold:ThresholdFilter;
		
		private var bodiesVec:Vector.<Body> = new Vector.<Body>();
		private var waterBodiesVecors:Vector.<Body>;
		private var img:Image;
		private var img2:Image;
		private var handJoint:PivotJoint;
		private var _batch:QuadBatch;
		private var image:Image;
		private var bodyList:BodyList;
		
		public function Game()
		{
			waterBodiesVecors = new Vector.<Body>();
			addEventListener(Event.ADDED_TO_STAGE, initilized);
		}
		
		private function initilized(e:Event):void
		{
			_debug = new BitmapDebug(stage.stageWidth, stage.stageHeight, stage.color, true);
			_debug.drawConstraints = true;
			_debug.drawBodies = false;
			Starling.current.nativeOverlay.addChild(_debug.display);
			
			var dButton:Button = new Button(Texture.fromColor(100,30, 0xffeeeeee, true), "Show Debug");
			dButton.addEventListener(Event.TRIGGERED, showDebugHandler);
			dButton.x = stage.stageWidth - dButton.width;
			dButton.y = 0;
			addChild(dButton);
			
			_space = new Space(new Vec2(0, 600));
			
			_threshold = new ThresholdFilter(0.9);
			
			_batch = new QuadBatch();
			_batch.filter = _threshold;
			addChild(_batch);
			
			drawWater(300);
			drawPlatforms();
			drawHandJoint();
						
			addEventListener(KeyboardEvent.KEY_DOWN, keyPressedHandler);
			addEventListener(TouchEvent.TOUCH, touchHandler);			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		
		private function drawWater(num:int):void{
			
			image = Image.fromBitmap(new Blue());
			var array:Array = Polygon.regular(4,4, 3);
			
			for (var i:int = 0; i < num; i++) 
			{
				image.pivotX = image.width/2;
				image.pivotY = image.height/2;
				
				var body:Body = new Body(BodyType.DYNAMIC);
				
				var material:Material = new Material();
				material.elasticity = 0;
				material.dynamicFriction = 0;
				material.staticFriction = 0;
				material.rollingFriction = 0;
				material.density = 1.6;
					
				body.shapes.add(new Polygon(array,material));
				body.position.setxy(Math.random() * 60 + 270, i*3 * -1);
				body.space = _space;
				
				waterBodiesVecors.push(body);
				_batch.addImage(image);
			}
			
		}
		
		private function updateWaterGraphics():void
		{
					
			_batch.reset();
			
			for (var i:int =0; i < waterBodiesVecors.length; i++) 
			{
				var body:Body = waterBodiesVecors[i];
				
				if(body.position.x > stage.stageWidth || body.position.x < 0){
					body.velocity = new Vec2(0,0);
					body.position.setxy(Math.random() * 60 + 270,0 );
				}
				
				image.x = body.position.x;
				image.y = body.position.y;
				
				_batch.addImage(image);
			}
			
		}
		
		
		private function loop(event:Event):void
		{
			_space.step(1/60);
			updateWaterGraphics();
			updateGraphics();
			
			_debug.clear();
			_debug.draw(_space);
			_debug.flush();
		}
		
		private function updateGraphics():void
		{
			for (var i:int = 0; i < bodyList.length; i++) 
			{
				var body:Body = bodyList.at(i);
				
				var graphic:DisplayObject = body.userData.graphic;
				graphic.x = body.position.x;
				graphic.y = body.position.y;
				graphic.rotation = body.rotation;
			}
			
			
		}
		
		private function drawPlatforms():void
		{
			var floor:Body = new Body(BodyType.STATIC);
			floor.shapes.add(new Polygon(Polygon.rect(0, stage.stageHeight-20, stage.stageWidth,10)));
			floor.space = _space;
			
			var wall_left:Body = new Body(BodyType.STATIC);
			wall_left.shapes.add(new Polygon(Polygon.rect(20,80,10,300)));
			wall_left.space = _space;
			
			var wall_right:Body = new Body(BodyType.STATIC);
			wall_right.shapes.add(new Polygon(Polygon.rect(stage.stageWidth - 20,80,10,300)));
			wall_right.space = _space;
			
			var ball:Shape = new Shape();
			ball.graphics.beginFill(0xff0000, 1);
			ball.graphics.drawCircle(50,50,50);
			ball.graphics.endFill();
			
			var ballData:BitmapData = new BitmapData(100,100, true, 0x000000);
			ballData.draw(ball);
			
			var ballImage:Image = Image.fromBitmap(new Bitmap(ballData,"auto",true));
			ballImage.pivotX = ballImage.width/2;
			ballImage.pivotY = ballImage.height/2;
			
			addChild(ballImage);
			
			bodyList = new BodyList();
			
			var circle:Body = new Body(BodyType.DYNAMIC);
			circle.shapes.add(new Circle(50, null, new Material(1.5,1,1,0.1)));
			circle.angularVel = 3;
			circle.position.x = 100;
			circle.userData.graphic = ballImage;
			circle.space = _space;
			bodyList.add(circle);			
		}	
		
		private function drawHandJoint():void
		{
			handJoint = new PivotJoint(_space.world, null, Vec2.weak(), Vec2.weak());
			handJoint.space = _space;
			handJoint.active = false;
			handJoint.stiff = false;
		}
		
		private function touchHandler(e:TouchEvent):void
		{
			
			var touch:Touch = e.getTouch(stage);
			if(touch == null) return;
			var position:Point = touch.getLocation(stage);
			
			if(touch.phase == TouchPhase.BEGAN){
				var mousePoint:Vec2  =Vec2.get(position.x, position.y);
				var bodies:BodyList = _space.bodiesUnderPoint(mousePoint);
				
				for (var i:int = 0; i < bodies.length; i++) 
				{
					var body:Body = bodies.at(i);
					
					if(!body.isDynamic()){
						continue;
					}
					
					handJoint.body2 = body;
					handJoint.anchor2.set(body.worldPointToLocal(mousePoint, true));
					handJoint.active = true;
					break;
				}
				mousePoint.dispose();
				
			}else if(touch.phase == TouchPhase.ENDED){
				handJoint.active = false;
				
			}else if(touch.phase == TouchPhase.MOVED){
				if(handJoint.active){
					handJoint.anchor1.setxy(position.x, position.y);
				}
			}
			
		}
		
		private function keyPressedHandler(e:KeyboardEvent):void
		{
			if(e.keyCode == 68){
				_debug.drawBodies = !_debug.drawBodies;
			}
			
		}	
		
		private function showDebugHandler(e:Event):void
		{
			var button:Button = Button(e.target);
			
			_debug.drawBodies = !_debug.drawBodies;
			button.text = !_debug.drawBodies ? "Show Debug" : "Hide Debug";
		}
		
	}
}