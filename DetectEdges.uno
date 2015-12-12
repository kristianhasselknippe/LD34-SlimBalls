using Uno;
using Uno.Graphics;
using Uno.UX;
using Fuse.Elements;
using Fuse.Designer;
using Fuse.Drawing.Primitives;

namespace Fuse.Effects
{
	public sealed class DetectEdges : BasicEffect
	{
		public DetectEdges() :
			base(EffectType.Composition)
		{
			Radius = 3;
		}

		float _radius;
		[Range(0, 100, 2)]
		public float Radius
		{
			get { return _radius; }
			set
			{
				if (_radius != value)
				{
					_radius = value;

					OnRenderingChanged();
					OnRenderBoundsChanged();
				}
			}
		}

		public override Rect ModifyRenderBounds( Rect inBounds )
		{
			return Rect.Inflate(inBounds, Padding);
		}

		internal float Sigma { get { return Math.Max(Radius, 1e-5f); } }
		internal float Padding
		{
			get { return Math.Ceil(Sigma * 3 * Element.AbsoluteZoom) / Element.AbsoluteZoom; }
		}

		float4 _color;
		public float4 Color
		{
			get { return _color; }
			set
			{
				if (value == _color) return;
				_color = value;
				OnRenderingChanged();
			}
		}

		float _threshold;
		public float Threshold
		{
			get { return _threshold; }
			set
			{
				if (value == _threshold) return;
				_threshold = value;
				OnRenderingChanged();
			}
		}

		float _smoothing;
		public float Smoothing
		{
			get { return _smoothing; }
			set
			{
				if (value == _smoothing) return;
				_smoothing = value;
				OnRenderingChanged();
			}
		}

		public float _spread = 1.0f;
		public float Spread
		{
			get { return _spread; }
			set
			{
				if (value == _spread) return;
				_spread = value;
				OnRenderingChanged();
			}
		}

		[Range(0, 5, 3)]
		float _strength = 1;
		public float Strength
		{
			get { return _strength; }
			set
			{
				if (value == _strength) return;
				_strength = value;
				OnRenderingChanged();
			}
		}

		[Color]
		float4 _backgroundColor = float4(1,1,1,1);
		public float4 BackgroundColor
		{
			get { return _backgroundColor; }
			set
			{
				if (value == _backgroundColor) return;
				_backgroundColor = value;
				OnRenderingChanged();
			}
		}

		[Color]
		float4 _edgeColor = float4(0,0,0,1);
		public float4 EdgeColor {
			get { return _edgeColor; }
			set
			{
				if (value == _edgeColor) return;
				_edgeColor = value;
				OnRenderingChanged();
			}
		}


		protected override void OnRender(DrawContext dc, Rect elementRect)
		{
			Rect paddedRect = Rect.Inflate(elementRect, Padding);

			// capture stuff
			var original = Element.CaptureRegion(dc, paddedRect, int2(0));
			if (original == null)
				return;



			draw Fuse.Drawing.Planar.Image
			{
				DrawContext: dc;
				Node: Element;
				Position: elementRect.Minimum - Padding;
				Invert: true;
				Size: paddedRect.Size;
				Texture: original.ColorBuffer;

				float2 delta: float2(Spread / original.Size.X, Spread / original.Size.Y);
				TexCoord: float2(prev.X, 1.0f - prev.Y);

				float4 origin : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y));

				float3 s1 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y)).XYZ;
				float3 s2 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y) + float2(delta.X, 0)).XYZ;
				float3 s3 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y) + float2(0, delta.Y)).XYZ;
				float3 s4 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y) + float2(-delta.X, 0)).XYZ;
				float3 s5 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y) + float2(0, -delta.Y)).XYZ;

				float3 s6 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y) + float2(delta.X, delta.Y)).XYZ;
				float3 s7 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y) + float2(delta.X, -delta.Y)).XYZ;
				float3 s8 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y) + float2(-delta.X, delta.Y)).XYZ;
				float3 s9 : sample(original.ColorBuffer, float2(TexCoord.X, 1 - TexCoord.Y) + float2(-delta.X, -delta.Y)).XYZ;

				float d1 : Vector.Length(s2 - s1);
				float d2 : Vector.Length(s3 - s1);
				float d3 : Vector.Length(s4 - s1);
				float d4 : Vector.Length(s5 - s1);

				float d5 : Vector.Length(s6 - s1);
				float d6 : Vector.Length(s7 - s1);
				float d7 : Vector.Length(s8 - s1);
				float d8 : Vector.Length(s9 - s1);

				float xx : Math.Min(1.0f, (d1+d2+d3+d4+d5+d6+d7+d8) * Strength);



				float4 edge : float4(EdgeColor.XYZ, EdgeColor.W * xx);
				float4 fill : origin;

				float3 color : fill.XYZ * (1-edge.W) + edge.XYZ * (edge.W);
				float alp : edge.W + fill.W;

				PixelColor: pixel( float4(color, alp));

			};

			FramebufferPool.Release(original);
		}
	}
}