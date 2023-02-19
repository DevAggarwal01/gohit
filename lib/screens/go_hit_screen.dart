import 'package:flutter/material.dart';
import 'package:gohit/screens/find_users.dart';

class GoHitScreen extends StatelessWidget {
  static const routeName = '/go-hit';

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        buildListTile(
            Icons.search,
            'Players',
            'Find athletes looking to hit near me',
            () => Navigator.of(context).pushNamed(FindUsers.routeName, arguments: "player"),
            context),
        buildListTile(
          Icons.sports_tennis,
          'Coaches',
          'Need a coach?',
          () => Navigator.of(context).pushNamed(FindUsers.routeName, arguments: "coach"),
          context,
        ),
        buildListTile(Icons.schedule, 'Schedule',
            'Find players available when I\'m free', () => null, context),
        buildListTile(Icons.location_city, 'Tennis courts',
            'Discover tennis courts near me', () => null, context),
      ],
    );
  }

  Widget buildListTile(IconData leading, String title, String subtitle,
      Function func, BuildContext context) {
    return InkWell(
      child: Container(
        height: 95,
        margin: EdgeInsets.all(10),
        child: Card(
          color: Theme.of(context).colorScheme.primary,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
            ),
            child: ListTile(
              leading: Icon(
                leading,
                size: 40,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: Text(
                title,
                style: Theme.of(context).textTheme.subtitle1,
              ),
              subtitle: FittedBox(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.subtitle2,
                ),
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
              ),
              trailing: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        ),
      ),
      onTap: () {
        func();
      },
    );
  }
}
