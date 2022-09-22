import 'package:car_helper/entities/order.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MoreOrderDetailArgs {
  final Order order;

  MoreOrderDetailArgs({required this.order});
}

class MoreOrderDetail extends StatefulWidget {
  const MoreOrderDetail({Key? key}) : super(key: key);

  @override
  State<MoreOrderDetail> createState() => _MoreOrderDetailState();
}

class _MoreOrderDetailState extends State<MoreOrderDetail> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as MoreOrderDetailArgs;
    final order = args.order;
    var before = order.photos.where((element) => element?.kind == 0);
    var after = order.photos.where((element) => element?.kind == 1);

    final DateFormat formatter = DateFormat("d MMMM yyyy, HH:mm");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.all(10.0),
              padding: const EdgeInsets.all(3.0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.black)),
              child: order.car?.plateNumber != ""
                  ? Text("${order.car?.plateNumber}")
                  : const Text("Гос.номер"),
            ),
          ],
        ),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text("Статус: ${order.status}"),
            Text("Комментарий к заявке: ${order.comment}"),
            Text("Авто: ${order.car?.brand} ${order.car?.model}"),
            Text("ГОС. Номер авто: ${order.car?.plateNumber}"),
            const Divider(),
            Text("Адрес откуда забрать авто: ${order.pickUpAddress}"),
            order.pickUpTime != null
                ? Text(
                    "Время указанное в заявке: ${formatter.format(order.pickUpTime!.toLocal())} ")
                : const Text("Время указанное в заявке:"),
            const Divider(),
            Text(
                "ФИО менеджера: ${order.employee?.lastName} ${order.employee?.firstName}"),
            Text(
                "ФИО водителя: ${order.driver?.lastName} ${order.driver?.firstName}"),
            Text("Номер телефона водителя: ${order.driver?.phone} "),
            const Divider(),
            const Text("Фотографии до выполнения заявки:"),
            GridView(
              physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0
                ),
            children: [
              for (var image in before)
                if (image != null)
                  PostTile(image.imageUrl)

            ],),

            const Text("Фотографии после выполнения заявки:"),
            GridView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0
              ),
              children: [
                for (var image in after)
                  if (image != null)
                    PostTile(image.imageUrl)

              ],),

          ],
        ),
      ),
    );
  }
}
class PostTile extends StatefulWidget {
  final String mediaUrl;
  const PostTile(this.mediaUrl, {Key? key}) : super(key: key);

  @override
  State<PostTile> createState() => _PostTileState();
}
class _PostTileState extends State<PostTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Image.network(widget.mediaUrl),
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                fullscreenDialog: true,
                builder: (BuildContext context) {
                  return Scaffold(
                    body: GestureDetector(
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height,
                        width: MediaQuery.of(context).size.width,
                        child: Hero(
                          tag: 'imageHero',
                          child: Image.network(
                            widget.mediaUrl,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  );
                }));
      },
    );
  }
}