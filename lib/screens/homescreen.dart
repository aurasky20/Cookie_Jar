import 'package:flutter/material.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String role = 'Pembeli';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Row(
          children: [
            SizedBox(height: 20),
            Expanded(
              child: Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 40,
                    crossAxisSpacing: 40,
                    // childAspectRatio: 4 / 5,
                  ),
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 250,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        SizedBox(height: 10),
                        Text('Judul'),
                        SizedBox(height: 20),
                        Text('deskripsi'),
                      ],
                    );
                  },
                ),
              ),
            ),
            (role == 'Admin')
                ? SubmitForm()
                : Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  decoration: BoxDecoration(
                    color: Color(0xffF3F3F3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: 500,

                  child: ListView(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail menu',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 20),
                      Container(height: 300, color: Colors.grey),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Nastar',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            "IDR 50.000",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Text("Stock : 30"),
                      SizedBox(height: 20),

                      Text(
                        "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Duis varius lacus orci. Phasellus convallis quam non metus consequat eleifend. Pellentesque sed neque vulputate, rhoncus nibh sed, tincidunt diam. Sed eget suscipit ex. Etiam semper tortor vel quam porttitor sodales. Fusce ullamcorper risus eu urna aliquam, id dapibus ante sagittis. Sed volutpat nibh eget lacus varius elementum. Sed semper, arcu vel pharetra tristique, elit dui dapibus urna, accumsan elementum nunc augue in turpis. Quisque pharetra tellus dolor, a fringilla nibh dictum id.",
                      ),
                      SizedBox(height: 20),

                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 1, // biar tetap ada bayangan
                        ),
                        child: Text(
                          'Checkout',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class SubmitForm extends StatelessWidget {
  const SubmitForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: Color(0xffF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      width: 500,

      child: ListView(
        // crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tambah menu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 20),
          Material(
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.hardEdge,
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                //fungsi media picker disini
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(width: 2, color: Colors.grey),

                  borderRadius: BorderRadius.circular(20),
                ),
                height: 260,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.photo_library), Text('Upload photo')],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20),
          Text('Nama Menu'),
          SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Nama Menu'),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('Nama Menu'),
                    SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text('Nama Menu'),
          SizedBox(height: 10),
          TextField(
            // minLines: 0,
            maxLines: 7,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 1, // biar tetap ada bayangan
            ),
            child: Text('Submit', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}
