import 'package:flutter/material.dart';
import 'package:wallet_connect/wallet_connect.dart';
import 'package:wallet_connect_explore/qrscan_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WCClient _wcClient;
  WCSessionStore? _sessionStore;
  TextEditingController _textEditingController = TextEditingController();
  late String walletAddress, privateKey;
  bool connected = false;

  void _qrScan(String value) {
    print(value);
    final session = WCSession.from(value);
    debugPrint('session $session');
    final peerMeta = WCPeerMeta(
      name: "Example Wallet",
      url: "https://example.wallet",
      description: "Example Wallet",
      icons: [
        "https://gblobscdn.gitbook.com/spaces%2F-LJJeCjcLrr53DcT1Ml7%2Favatar.png"
      ],
    );
    _wcClient.connectNewSession(session: session, peerMeta: peerMeta);
  }

  _onSessionRequest(int id, WCPeerMeta peerMeta) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Column(
            children: [
              if (peerMeta.icons.isNotEmpty)
                Container(
                  height: 100.0,
                  width: 100.0,
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Image.network(peerMeta.icons.first),
                ),
              Text(peerMeta.name),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            if (peerMeta.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(peerMeta.description),
              ),
            if (peerMeta.url.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Connection to ${peerMeta.url}'),
              ),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () async {
                      _wcClient.approveSession(
                        accounts: [walletAddress],
                        // TODO: Mention Chain ID while connecting
                        chainId: 1,
                      );
                      _sessionStore = _wcClient.sessionStore;
                      // await _prefs.setString('session',
                      //     jsonEncode(_wcClient.sessionStore.toJson()));
                      Navigator.pop(context);
                    },
                    child: Text('APPROVE'),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      primary: Colors.white,
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                    ),
                    onPressed: () {
                      _wcClient.rejectSession();
                      Navigator.pop(context);
                    },
                    child: Text('REJECT'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _onConnect() {
    setState(() {
      connected = true;
    });
  }

  _onSessionClosed(int? code, String? reason) {
    setState(() {
      connected = false;
    });

    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Text("Session Ended"),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Some Error Occured. ERROR CODE: $code'),
            ),
            if (reason != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Failure Reason: $reason'),
              ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('CLOSE'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _onSign(int code, WCEthereumSignMessage wcEthereumSignMessage) {
    showDialog(
      context: context,
      builder: (_) {
        return SimpleDialog(
          title: Text("Session Ended"),
          contentPadding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 16.0),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text('Some Error Occured. ERROR CODE: $code'),
            ),
            if (wcEthereumSignMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text('Failure Reason: ${wcEthereumSignMessage.data}'),
              ),
            Row(
              children: [
                TextButton(
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('CLOSE'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  _initialize() async {
    _wcClient = WCClient(
      onSessionRequest: _onSessionRequest,
      // onFailure: _onSessionError,
      onDisconnect: _onSessionClosed,
      onEthSign: _onSign,
      // onEthSignTransaction: _onSignTransaction,
      // onEthSendTransaction: _onSendTransaction,
      onCustomRequest: (_, __) {},
      onConnect: _onConnect,
    );
    // TODO: Mention walletAddress and privateKey while connecting
    walletAddress = '0xF82b9dc37ac4b76274a3826725Ac84344582Dd18';
    privateKey =
        'eb3b5c1dcaee30f5d060440e72665f49e00f6d3078075c827d7c0f46a9e366c2';
    // _textEditingController = TextEditingController();
    // _prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$connected',
            ),
            ElevatedButton(
                onPressed: () {
                  _wcClient.killSession();
                },
                child: const Text('Kill Season')),
            ElevatedButton(
                onPressed: () {
                  showGeneralDialog(
                      context: context,
                      barrierDismissible: true,
                      barrierLabel: 'Paste Code',
                      pageBuilder: (context, _, __) {
                        return SimpleDialog(
                          title: Text('Paste code to connect'),
                          titlePadding:
                              const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, .0),
                          contentPadding: const EdgeInsets.all(16.0),
                          children: [
                            TextField(
                              controller: _textEditingController,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                label: Text('Enter Code'),
                              ),
                            ),
                            const SizedBox(height: 16.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('CONTINUE'),
                                ),
                              ],
                            ),
                          ],
                        );
                      }).then((_) {
                    if (_textEditingController.text.isNotEmpty) {
                      _qrScan(_textEditingController.text);
                      _textEditingController.clear();
                    }
                  });
                },
                child: Text('Paste Code'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QRScanPage()),
          ).then((value) {
            if (value != null) {
              _qrScan(value);
            }
          });
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
