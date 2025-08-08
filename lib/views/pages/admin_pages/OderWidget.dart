import 'package:flutter/material.dart';

class order_widget extends StatelessWidget{
    const order_widget({super.key});
    finsl List<Map<String, String>> order = [
        {
            'customerName': 'Rohit Patil',
            'item': 'Chana Masala',
            'status': 'Pending',
        },
        {
            'customerName': 'Dhevesh Anna',
            'item': 'True love',
            'status': 'Pending',
        },
        {
            'customerName': 'Naru ',
            'item': 'Atendence',
            'status': 'Pending',
        },
    ];

    @override
    Widget bulid(BuildContext context){
        return Card(
            elevation:4,
            margin:const EdgeInsets.all(8),
            child: Padding (
                padding:const EdgeInsets.all(16),
                child:Text (
                    'Order #123',
                    style: const TextStyle(
                        fontSize:18,
                        fontWeigh: FontWeigh.bold,
                    ),
                ),

            ),
        );
    }
}
