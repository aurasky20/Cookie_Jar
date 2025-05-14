import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Data extends StatefulWidget {
  const Data({Key? key}) : super(key: key);

  @override
  State<Data> createState() => _DataState();
}

class _DataState extends State<Data> {
  final supabase = Supabase.instance.client;
  List data = [];

  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          delete();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('Get Data'),
        actions: [
          IconButton(
            onPressed: () {
              get();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Container(
        child: Column(
          children:
              data
                  .map(
                    (e) => ListTile(
                      // leading:
                      //     e['link_foto'] != null && e['link_foto'] != ''
                      //         ? CircleAvatar(
                      //           backgroundImage: NetworkImage(e['link_foto']),
                      //         )
                      //         : CircleAvatar(backgroundColor: Colors.amber),
                      // title: Text(e['nama_produk']),
                      // subtitle: Text(formatRupiah.format(e['harga'])),
                      leading: CircleAvatar(backgroundColor: Colors.amber),
                      title: Text(e['username']),
                      subtitle: Text(e['email']),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }

  //get
  get() async {
    // final response = await supabase.from('produk').select('*');
    final response = await supabase
        .from('pembeli')
        .select('username, email');
    setState(() {
      data = response;
    });
  }

  //insert
  insert() async {
    try {
      final response = await supabase.from('pembeli').insert({
        'username': 'alfian',
        'email': 'alfian@gmail.com',
        'password': 'alfian123',
      });

      // Cek jika response berhasil
      print('Insert success: $response');

      // Refresh data setelah insert
      get();
    } catch (e) {
      print('Insert error: $e');
    }
  }

  //update
  update() async {
    try {
      final response = await supabase
          .from('pembeli')
          .update({'username': 'alfian24'})
          .eq('id', 6);
      // Cek jika response berhasil
      print('Update success: $response');
      // Refresh data setelah update
      get();
    } catch (e) {
      print('Update error: $e');
    }
  }

  // delete
  delete() async {
    try {
      final response = await supabase.from('pembeli').delete().eq('id', 6);
      // Cek jika response berhasil
      print('Delete success: $response');
      // Refresh data setelah delete
      get();
    } catch (e) {
      print('Delete error: $e');
    }
  }
}
