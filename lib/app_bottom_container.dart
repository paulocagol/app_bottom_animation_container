import 'package:flutter/material.dart';
import 'package:smooth_sheets/smooth_sheets.dart';

class Product {
  final int id;
  final String img;

  Product({required this.id, required this.img});
}

List<Product> products = List.generate(
  999,
  (index) => Product(id: index, img: 'assets/img.png'),
);

const minProportionalExtent = 0.0;
const middleProportionalExtent = 0.1;
const maxProportionalExtent = 0.9;

class AppBottomContainer extends StatefulWidget {
  final Widget child;

  const AppBottomContainer({super.key, required this.child});

  @override
  AppBottomContainerState createState() => AppBottomContainerState();

  static AppBottomContainerState of(BuildContext context) {
    final AppBottomContainerState? result = context.findAncestorStateOfType<AppBottomContainerState>();
    assert(result != null, 'No AppBottomContainer found in context');
    return result!;
  }
}

class AppBottomContainerState extends State<AppBottomContainer> with SingleTickerProviderStateMixin {
  double currentExtent = 0.2;
  late final SheetController _sheetController;
  late final HeroController _heroController;
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _sheetController = SheetController();
    _heroController =
        HeroController(createRectTween: (Rect? begin, Rect? end) => MaterialRectArcTween(begin: begin, end: end));

    _sheetController.addListener(() {
      final metrics = _sheetController.value;
      setState(() {
        currentExtent = metrics.pixels / metrics.maxPixels;

        // Check current route and navigate accordingly
        if (currentExtent > 0.4) {
          if (!_isVerticalListRouteActive()) {
            _navigatorKey.currentState?.pushNamed("/vertical");
          }
        } else {
          if (_isVerticalListRouteActive()) {
            _navigatorKey.currentState?.popUntil((route) => route.isFirst);
          }
        }
      });
    });
  }

  bool _isVerticalListRouteActive() => _navigatorKey.currentState?.canPop() ?? false;

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  Future<void> show() async => await _sheetController.animateTo(
        const Extent.proportional(middleProportionalExtent),
        duration: const Duration(milliseconds: 100),
      );

  Future<void> max() async => await _sheetController.animateTo(
        const Extent.proportional(maxProportionalExtent),
        duration: const Duration(milliseconds: 100),
      );

  Future<void> hide() async => await _sheetController.animateTo(
        const Extent.pixels(middleProportionalExtent),
        duration: const Duration(milliseconds: 100),
      );

  @override
  Widget build(BuildContext context) {
    double borderRadiusValue = 16 * currentExtent;
    double shadowOpacity = 0.2 + (0.3 * currentExtent);

    // Definindo a opacidade mínima da sombra e aumentando gradualmente
    double minSheetShadowOpacity = 0.1; // Opacidade mínima da sombra
    double maxSheetShadowOpacity = 0.4; // Opacidade máxima da sombra
    double sheetShadowOpacity = currentExtent > maxProportionalExtent
        ? minSheetShadowOpacity + (maxSheetShadowOpacity - minSheetShadowOpacity) * currentExtent
        : 0.0;

    // Adicionando a lógica para escalar e transladar gradualmente
    double scaleEffect = currentExtent > maxProportionalExtent
        ? 1.0 - (0.1 * (currentExtent - maxProportionalExtent) * 5).clamp(0.0, 0.1)
        : 1.0;
    double translateEffect =
        currentExtent > maxProportionalExtent ? 50 * (currentExtent - maxProportionalExtent) * 5 : 0.0;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadiusValue),
              border: Border.all(
                color: Colors.grey.withOpacity(0.5),
                width: 2.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(shadowOpacity),
                  blurRadius: 10,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Transform.scale(
              scale: scaleEffect, // Ajusta a escala da tela de fundo
              child: Transform.translate(
                offset: Offset(0, translateEffect), // Ajusta a posição da tela de fundo
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadiusValue),
                  child: widget.child,
                ),
              ),
            ),
          ),
          DraggableSheet(
            controller: _sheetController,
            minExtent: const Extent.proportional(minProportionalExtent),
            maxExtent: const Extent.proportional(maxProportionalExtent),
            initialExtent: const Extent.pixels(0.0),
            physics: BouncingSheetPhysics(
              parent: SnappingSheetPhysics(
                snappingBehavior: SnapToNearest(
                  snapTo: [
                    const Extent.proportional(minProportionalExtent),
                    const Extent.proportional(middleProportionalExtent),
                    const Extent.proportional(maxProportionalExtent),
                  ],
                ),
              ),
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    currentExtent > maxProportionalExtent
                        ? const SizedBox.shrink()
                        : Container(
                            height: 10,
                            width: 100,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Divider(
                              thickness: 2,
                              color: Colors.black.withOpacity(0.5),
                              height: 1,
                              indent: 20,
                              endIndent: 20,
                            ),
                          ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(sheetShadowOpacity),
                            blurRadius: 10,
                            spreadRadius: 0.1,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: SizedBox(
                        height: constraints.maxHeight - 10,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                          child: Navigator(
                            key: _navigatorKey,
                            observers: [_heroController],
                            onGenerateRoute: (RouteSettings settings) {
                              return PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 1000), // Define a duração de transição
                                reverseTransitionDuration: const Duration(milliseconds: 1000),
                                barrierColor: Colors.green,
                                opaque: true,
                                settings: settings,

                                pageBuilder: (context, animation, secondaryAnimation) {
                                  if (settings.name == "/vertical") {
                                    return _buildVerticalList();
                                  }
                                  return _buildHorizontalList();
                                },
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  const begin = Offset(1.0, 0.0);
                                  const end = Offset.zero;
                                  const curve = Curves.fastOutSlowIn;

                                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                                  var offsetAnimation = animation.drive(tween);

                                  return SlideTransition(
                                    position: offsetAnimation,
                                    child: child,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalList() {
    return Column(
      children: [
        Container(
          height: currentExtent > maxProportionalExtent ? 0 : 50,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: SizedBox(
            height: 50,
            child: AnimatedList(
              scrollDirection: Axis.horizontal,
              initialItemCount: products.length,
              itemBuilder: (context, index, animation) {
                final product = products[index];
                return Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: Hero(
                    tag: 'product_${product.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        product.img,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 18.0, top: 12.0),
            child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                height: 50,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Produtos 10',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total R\$ 750,00',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                )),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.only(
              top: 0,
              bottom: 18.0,
              left: 18.0,
              right: 18.0,
            ),
            height: MediaQuery.of(context).size.height - 110,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Positioned(
                  top: -50,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    // height: MediaQuery.of(context).size.height,
                    child: AnimatedList(
                      primary: true,
                      shrinkWrap: true,
                      initialItemCount: products.length,
                      itemBuilder: (context, index, animation) {
                        final product = products[index];
                        return Container(
                          height: 80,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Hero(
                                tag: 'product_${product.id}',
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    product.img,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Produto ${product.id}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'R\$${product.id * 100}',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
