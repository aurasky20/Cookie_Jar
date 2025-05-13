import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Data extends StatefulWidget {
  const Data({Key? key}) : super(key: key);

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  final supabase = Supabase.instance.client;
  List data = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          get();
        },
        child: const Icon(Icons.add),
    ),
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => Data()));
            },
            icon: const Icon(Icons.refresh),
          )
        ],
      ),
      body: Container(
        child: Column(
          children: data.map((e) => ListTile(
            leading: e['link_foto']!='null' ? CircleAvatar(backgroundImage: e['link_foto'],): CircleAvatar(backgroundColor: Colors.amber,),
            title: Text(e['nama_produk']),
            subtitle: Text(e['harga']),
          ),).toList(),
      ),)
    );
  }
  //get
  get () async {
    final data = await supabase.from('produk').select('*');
    print(data);
    // if (response.error == null) {
    //   setState(() {
    //     data = response.data;
    //   });
    // } else {
    //   print(response.error!.message);
    // }
  }
}




//insert

//update

//delete