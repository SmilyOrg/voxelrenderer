package  {
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix3D;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import no.doomsday.console.ConsoleUtil;
	public class Renderer extends EventDispatcher {
		
		private var w:int;
		private var h:int;
		
		private var sx:int = 150;
		private var sy:int = 150;
		private var sz:int = 150;
		private var rotationSpeed:Number = 0.5;
		//private var rotationSpeed:Number = 2;
		
		private var bufferLimit:int = 65535;
		private var dataPerVertex:int = 3;
		
		private var blocks:Vector.<int> = new Vector.<int>(sx*sy*sz);
		
		private var numVertices:int = 0;
		private var vertices:Vector.<Number> = new Vector.<Number>();
		private var numIndices:int = 0;
		private var indices:Vector.<uint> = new Vector.<uint>();
		
		private var context:Context3D;
		
		//private var vertexBuffer:VertexBuffer3D;
		//private var indexBuffer:IndexBuffer3D;
		
		private var vertexBuffers:Vector.<VertexBuffer3D> = new Vector.<VertexBuffer3D>();
		private var indexBuffers:Vector.<IndexBuffer3D> = new Vector.<IndexBuffer3D>();
		
		private var stage3D:Stage3D;
		private var program:Program3D;
		private var camera:Matrix3D;
		private var rotX:Number = 0;
		private var rotY:Number = 0;
		private var buffers:int;
		private var currentBufferIndex:int = 0;
		
		public function Renderer() { }
		
		public function init(stage3D:Stage3D, w:int, h:int):void {
			this.stage3D = stage3D;
			this.w = w;
			this.h = h;
			
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, initContext);
			stage3D.viewPort = new Rectangle(0, 0, w, h);
			stage3D.requestContext3D(Context3DRenderMode.AUTO);
			//stage3D.requestContext3D("directx9");
			
			ConsoleUtil.createCommand("setbuf",
				function(cur:int):void {
					currentBufferIndex = cur;
				}
			);
		}
		
		private function initContext(e:Event):void {
			context = stage3D.context3D;
			context.configureBackBuffer(w, h, 0);
			context.enableErrorChecking = true;
			
			var vertexShader:Array =
			[
				//"m44 op, va0, vc0"
				"m44 vt0, va0, vc0",
				"mov op, vt0",
				"mov v0, vt0.z"
			];
			
			var vertexShaderAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble(Context3DProgramType.VERTEX, vertexShader.join("\n"));
			
			//var farplane:Number = 0.05;
			//var farplane:Number = 20;
			//var farplane:Number = 50;
			var farplane:Number = 100;
			//var farplane:Number = 80;
			//var farplane:Number = 10+sx*2;
			context.setProgramConstantsFromVector(Context3DProgramType.FRAGMENT, 0, new <Number>[
				0, 0, 0, 1,
				0.7, 0.7, 0.7, 1,
				farplane, farplane, farplane, farplane
			]);
			var fragmentShader:Array =
			[
				"div ft0, fc2, v0",
				"mul ft1, ft0, fc0",
				"rcp ft0, ft0",
				"mul ft2, ft0, fc1",
				"add ft1, ft1, ft2",
				"mov oc, ft1"
			];
			var fragmentAssembler:AGALMiniAssembler = new AGALMiniAssembler();
			fragmentAssembler.assemble(flash.display3D.Context3DProgramType.FRAGMENT, fragmentShader.join("\n"));
			
			program = context.createProgram();
			program.upload(vertexShaderAssembler.agalcode, fragmentAssembler.agalcode);
			
			//indexBuffer.uploadFromVector(indices, 0, indices.length);
			
			//context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_2); //xy
			//context.setVertexBufferAt(1, vertexBuffer, 2, Context3DVertexBufferFormat.FLOAT_2); //uv
			//context.setTextureAt(0, texture);
			
			context.setProgram(program);
			
			context.setCulling(Context3DTriangleFace.BACK);
			//context.setCulling(Context3DTriangleFace.FRONT);
			
			camera = new Matrix3D();
			
			constructGeometry();
			
			//render();
			
			dispatchEvent(new Event(Event.INIT));
		}
		
		private function getBlockId(x:int, y:int, z:int):int {
			if (x < 0 || y < 0 || z < 0 || x >= sx || y >= sy || z >= sz) return 0;
			return blocks[x%sx+(y%sy)*sx+(z%sz)*sx*sy];
		}
		private function setBlockId(x:int, y:int, z:int, bid:int):void {
			if (x < 0 || y < 0 || z < 0 || x >= sx || y >= sy || z >= sz) return;
			blocks[x%sx+(y%sy)*sx+(z%sz)*sx*sy] = bid;
		}
		private function constructGeometry():void {
			var i:int;
			/*
			for (i = 0; i < blocks.length; i++) {
				blocks[i] = Math.random() > 0.9 ? 1 : 0;
				//blocks[i] = (i%sx) == 0 && (i%(sx*sy)) == 0 && (i%(sx*sy*sz)) == 0 ? 1 : 0;
			}
			//*/
			var x:int, y:int, z:int;
			///*
			for (z = 0; z < sz; z++) {
				for (y = 0; y < sy; y++) {
					for (x = 0; x < sx; x++) {
						setBlockId(x, y, z, x%2 == 0 && y%2 == 0 && z%2 == 0 ? 1 : 0);
					}
				}
			}
			//*/
			
			///*
			for (z = -1; z < sz+1; z++) {
				for (y = -1; y < sy+1; y++) {
					for (x = -1; x < sx+1; x++) {
						var bid:int = getBlockId(x, y, z);
						if (bid == 0) {
							addNeighbor(x, y, z, -1, 0, 0);
							addNeighbor(x, y, z, 1, 0, 0);
							addNeighbor(x, y, z, 0, -1, 0);
							addNeighbor(x, y, z, 0, 1, 0);
							addNeighbor(x, y, z, 0, 0, -1);
							addNeighbor(x, y, z, 0, 0, 1);
						}
					}
				}
			}
			//*/
			
			//addQuad(0, 0, 0, 0);
			//addQuad(0, 0, 0, 1);
			//addQuad(0, 0, 0, 2);
			
			/*
			var index:int;
			
			index = vertices.length;
			vertices[index++] = 0;
			vertices[index++] = 0;
			vertices[index++] = 0;
			
			vertices[index++] = 1;
			vertices[index++] = 0;
			vertices[index++] = 0;
			
			vertices[index++] = 1;
			vertices[index++] = 1;
			vertices[index++] = 0;
			numVertices += 3;
			
			index = indices.length;
			indices[index++] = 0;
			indices[index++] = 1;
			indices[index++] = 2;
			numIndices += 3;
			*/
			
			while (vertexBuffers.length > 0) {
				vertexBuffers.pop().dispose();
			}
			while (indexBuffers.length > 0) {
				indexBuffers.pop().dispose();
			}
			
			//buffers = Math.ceil(numVertices/bufferLimit);
			//for (i = 0; i < buffers; i++) {
				//var len:int = i == buffers-1 ? numVertices-(buffers-1)*bufferLimit : bufferLimit;
			
			var verticesLeft:int = numVertices;
			var vertOffset:int = 0;
			var indOffset:int = 0;
			buffers = 0;
			while (verticesLeft > 0) {
			//for (i = 0; i < 3; i++) {
				var vertLen:int;
				
				var alignedLeft:int = Math.ceil(verticesLeft/4)*4;
				if (alignedLeft >= bufferLimit) {
					vertLen = bufferLimit;
					vertLen = int(vertLen/4)*4;
				} else {
					vertLen = alignedLeft;
				}
				verticesLeft -= vertLen;
				
				//vertLen = 16;
				
				
				var indLen:int = int(vertLen/4)*6;
				
				//ConsoleUtil.print("Creating buffer "+buffers+" vertex "+vertLen+" "+vertOffset+"   index "+indLen+" "+indOffset);
				
				var vb:VertexBuffer3D = context.createVertexBuffer(vertLen, dataPerVertex);
				vb.uploadFromVector(vertices.slice(vertOffset*dataPerVertex, (vertOffset+vertLen)*dataPerVertex), 0, vertLen);
				vertexBuffers.push(vb);
				
				var offsetIndices:Vector.<uint> = new Vector.<uint>(indLen);
				for (i = 0; i < indLen; i++) {
					offsetIndices[i] = int(i/6)*4+indices[indOffset+i];
				}
				
				var ib:IndexBuffer3D = context.createIndexBuffer(indLen);
				ib.uploadFromVector(offsetIndices, 0, indLen);
				indexBuffers.push(ib);
				
				//ConsoleUtil.print("Creating buffer "+buffers+" vertex "+vertLen+" / "+slicedVerts.length+" "+vertOffset+"   index "+indLen+" "+indOffset);
				//ConsoleUtil.print("Creating buffer "+buffers+" vertex "+vertLen+" "+vertOffset+"   index "+indLen+" "+indOffset+"    "+slicedIndices.length);
				
				vertOffset += vertLen;
				indOffset += indLen;
				buffers++;
				
				//var offset:int = i*bufferLimit;
				//var aligned:int = 
				
				//ConsoleUtil.print("Creating buffer "+i+" "+len+" / "+numVertices);
				
				/*
				var vb:VertexBuffer3D = context.createVertexBuffer(len, 3);
				vb.uploadFromVector(vertices, offset, len);
				vertexBuffers.push(vb);
				
				var ib:IndexBuffer3D = context.createIndexBuffer(len);
				ib.uploadFromVector(indices, offset, len);
				indexBuffers.push(ib);
				*/
				
			}
			ConsoleUtil.print("Buffers: "+buffers+" at approx. "+bufferLimit+" vertices each");
			ConsoleUtil.print("Vertices: "+numVertices);
			ConsoleUtil.print("Indices: "+numIndices);
			ConsoleUtil.print("Triangles: "+numIndices/3);
			
			//vertexBuffer = context.createVertexBuffer(numVertices, 3);
			//vertexBuffer.uploadFromVector(vertices, 0, numVertices);
			//context.setVertexBufferAt(0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			
			//indexBuffer = context.createIndexBuffer(numIndices);
			//indexBuffer.uploadFromVector(indices, 0, numIndices);
		}
		
		private function addNeighbor(x:int, y:int, z:int, dx:int, dy:int, dz:int):void {
			var bid:int = getBlockId(x+dx, y+dy, z+dz);
			if (bid > 0) {
				//addQuad(x+0.5+dx/2, y+0.5+dy/2, z+0.5+dz/2, dx != 0 ? 0 : (dy != 0 ? 1 : 2));
				var plane:int = dx != 0 ? 0 : (dy != 0 ? 1 : 2);
				if (dx != 0) addQuad(x+(dx+1)/2, y, z, plane, dx);
				if (dy != 0) addQuad(x, y+(dy+1)/2, z, plane, -dy);
				if (dz != 0) addQuad(x, y, z+(dz+1)/2, plane, dz);
			}
		}
		
		private function addQuad(x:Number, y:Number, z:Number, plane:int, order:int):void {
			var index:int;
			
			index = vertices.length;
			switch (plane) {
				case 0: // X PLANE
					vertices[index++] = x;
					vertices[index++] = y;
					vertices[index++] = z;
					
					vertices[index++] = x;
					vertices[index++] = y+1;
					vertices[index++] = z;
					
					vertices[index++] = x;
					vertices[index++] = y+1;
					vertices[index++] = z+1;
					
					vertices[index++] = x;
					vertices[index++] = y;
					vertices[index++] = z+1;
					break;
				case 1: // Y PLANE
					vertices[index++] = x;
					vertices[index++] = y;
					vertices[index++] = z;
					
					vertices[index++] = x+1;
					vertices[index++] = y;
					vertices[index++] = z;
					
					vertices[index++] = x+1;
					vertices[index++] = y;
					vertices[index++] = z+1;
					
					vertices[index++] = x;
					vertices[index++] = y;
					vertices[index++] = z+1;
					break;
				case 2: // Z PLANE
					vertices[index++] = x;
					vertices[index++] = y;
					vertices[index++] = z;
					
					vertices[index++] = x+1;
					vertices[index++] = y;
					vertices[index++] = z;
					
					vertices[index++] = x+1;
					vertices[index++] = y+1;
					vertices[index++] = z;
					
					vertices[index++] = x;
					vertices[index++] = y+1;
					vertices[index++] = z;
					break;
			}
			
			///*
			index = indices.length;
			if (order > 0) {
				// CCW
				indices[index++] = 0;
				indices[index++] = 1;
				indices[index++] = 2;
				
				indices[index++] = 2;
				indices[index++] = 3;
				indices[index++] = 0;
			} else {
				// CW
				indices[index++] = 0;
				indices[index++] = 2;
				indices[index++] = 1;
				
				indices[index++] = 2;
				indices[index++] = 0;
				indices[index++] = 3;
			}
			//*/
			
			numVertices += 4;
			numIndices += 6;
		}
		
		
		private function perspectiveProjection(fov:Number = 90, aspect:Number = 1, near:Number = 1, far:Number = 2048):Matrix3D {
			var y2:Number = near * Math.tan(fov * Math.PI / 360);
			var y1:Number = -y2;
			var x1:Number = y1 * aspect;
			var x2:Number = y2 * aspect;
			
			var a:Number = 2 * near / (x2 - x1);
			var b:Number = 2 * near / (y2 - y1);
			var c:Number = (x2 + x1) / (x2 - x1);
			var d:Number = (y2 + y1) / (y2 - y1);
			var q:Number = -(far + near) / (far - near);
			var qn:Number = -2 * (far * near) / (far - near);
			
			return new Matrix3D(Vector.<Number>([
				a, 0, 0, 0,
				0, b, 0, 0,
				c, d, q, -1,
				0, 0, qn, 0
			]));
		}
		
		public function run(toggle:Boolean = false, v:Number = 0):void {
			camera.identity();
			camera.appendRotation(rotX, Vector3D.X_AXIS);
			camera.appendRotation(rotY, Vector3D.Y_AXIS);
			//camera.appendTranslation(0, 0, -5);
			//camera.appendTranslation(0, 0, -15);
			//camera.appendTranslation(0, 0, -20);
			//camera.appendTranslation(0, 0, -25);
			camera.appendTranslation(0, 0, -10-sx);
			//camera.appendTranslation(0, 0, -90);
			//rotX += Math.PI-3;
			//rotY += 1;
			//rotX += rotationSpeed;
			rotX += (Math.PI-3)*rotationSpeed;
			rotY += rotationSpeed;
			render(toggle, v);
		}
		private function render(toggle:Boolean = false, v:Number = 0):void {
			context.clear(1, 1, 1, 0);
			
			var mvp:Matrix3D = new Matrix3D();
			
			var viewMatrix:Matrix3D = new Matrix3D();
			viewMatrix.appendTranslation(-sx/2, -sy/2, -sz/2);
			mvp.append(viewMatrix);
			
			//camera.appendScale(100, 100, 100);
			mvp.append(camera);
			
			//mvp.append(perspectiveProjection(90, 1, 1, 100));
			mvp.append(perspectiveProjection(90, w/h));
			//mvp.append(perspectiveProjection(90, 1, 0.5));
			
			context.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, mvp, true);
			
			//var i:int = currentBufferIndex;
			
			var startBuffer:int;
			var endBuffer:int;
			
			if (toggle) {
				startBuffer = int(v*buffers);
				endBuffer = startBuffer+1;
			} else {
				startBuffer = 0;
				endBuffer = buffers;
			}
			
			for (var i:int = startBuffer; i < endBuffer; i++) {
				var vb:VertexBuffer3D = vertexBuffers[i];
				var ib:IndexBuffer3D = indexBuffers[i];
				context.setVertexBufferAt(0, vb, 0, Context3DVertexBufferFormat.FLOAT_3);
				context.drawTriangles(ib);
			}
			
			//context.drawTriangles(indexBuffer);
			context.present();
		}
	}
}