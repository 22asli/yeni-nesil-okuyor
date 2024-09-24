import 'package:bookapp/utils/context_extension.dart';
import 'package:flutter/material.dart';

class ElevatedButtonWidget extends StatefulWidget {
  const ElevatedButtonWidget({
    super.key,
    required this.title,
    this.padding,
    this.isEnable = true,
    this.height,
    this.color,
    required this.onPressed,
  });

  final String title;
  final Future<void> Function()? onPressed;
  final double? padding;
  final bool? isEnable;
  final double? height;
  final Color? color;

  @override
  State<ElevatedButtonWidget> createState() => _ElevatedButtonWidgetState();
}

class _ElevatedButtonWidgetState extends State<ElevatedButtonWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: false);

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: widget.padding ?? 10, vertical: 3),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(vertical: 0, horizontal: 0),
          ),
          backgroundColor: WidgetStateProperty.all(
            widget.isEnable == true
                ? widget.color ?? Colors.deepOrange
                : Colors.grey,
          ),
          elevation: WidgetStateProperty.all(0),
          fixedSize: WidgetStateProperty.all(
            Size(
              context.dynamicWidth(1),
              context.dynamicHeight(widget.height ?? 18),
            ),
          ),
          shape: WidgetStateProperty.all(
            const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(26),
              ),
            ),
          ),
        ),
        onPressed: widget.isEnable == true
            ? () async {
                if (widget.onPressed != null) {
                  await widget.onPressed!();
                }
              }
            : null,
        child: Stack(
          children: [
            widget.isEnable == false
                ? const SizedBox()
                : _buildButtonAnimation(),
            Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  AnimatedBuilder _buildButtonAnimation() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.0),
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.0),
              ],
              stops: [
                _animation.value - 0.1,
                _animation.value,
                _animation.value + 0.1,
              ],
            ).createShader(rect);
          },
          blendMode: BlendMode.srcIn,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
            ),
          ),
        );
      },
    );
  }
}
