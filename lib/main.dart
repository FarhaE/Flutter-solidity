

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web3dart/web3dart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voting App',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
    late Client httpClient;
  late Web3Client ethClient;

  //Ethereum address 
  final String myAddress = "0x8fF1b659bDC9D6eF5d99823B155cfdf47eF2944d";

  //url from Infura
  final String blockChainUrl="https://rinkeby.infura.io/v3/4e577288c5b24f17a04beab17cf9c959";

  //value of alpha and beta
  var totalVotesA;
  var totalVotesB;

  @override
  void initState() {
    httpClient =Client();
    ethClient=Web3Client(blockChainUrl, httpClient);
    getTotalVotes();
    super.initState();
  }
  Future<DeployedContract>getContract() async{ 
  //deployed contract class from the web3dart package is used to construct contract
  //it requires abi file which is in json format, contractaddress in hex format
String abiFile= await rootBundle.loadString("assets/contract.json");
String contractAddress= "0xee3F5a4361ec47C57394Fc028C3fBCCd0e9f1B5d";
final contract= DeployedContract(ContractAbi.fromJson(abiFile, "Voting"), EthereumAddress.fromHex(contractAddress));
return contract;
  }  
  Future<List<dynamic>> callFunction(String name) async{
    final contract=await getContract();
    final function=contract.function(name);
    final result=await ethClient.call(contract: contract, function: function, params: []);
    //The line above is how we connect to our smart contract with the call extension 
    //from the web3dart EthereumClient class. 
    //The result of this operation is a list that the function returns:
    return result;
  }

Future<void> getTotalVotes() async{
  List<dynamic> resultsA=await callFunction("getTotalVotesAplha");
  List<dynamic> resultsB=await callFunction("getTotalVotesBeta");
  totalVotesA = resultsA[0];
  totalVotesB = resultsB[0];
setState(() {
  
});
}

Future<void> vote(bool voteAlpha) async {
  snackBar(label: "Recording vote");
  //obtain private key for write operation
  Credentials key = EthPrivateKey.fromHex("f6417d3d4c5cc294ace85aa196fcde0ca792550e085f65fff459423e597ff306");
final contract= await getContract();
final function = contract.function(voteAlpha ? "voteAlpha" : "voteBeta",);

//send transaction usinf our private key, function and contract
await ethClient.sendTransaction(key, Transaction.callContract(contract: contract, function: function, parameters: []),chainId: 5);
}

  @override
  Widget build(BuildContext context) {
   
    return Scaffold(
      appBar: AppBar(
       
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        
        title: Text(widget.title),
      ),
      body: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(30),
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(20))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        CircleAvatar(
                          child: Text("A"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          "Total Votes:0",
                          //${totalVotesA ?? ""}",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                    Column(
                      children: [
                        CircleAvatar(
                          child: Text("B"),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("Total Votes:0", 
                       // ${totalVotesB ?? ""}",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold))
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                    //  vote(true);
                    },
                    child: Text('Vote Alpha'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    onPressed: () {
                     // vote(false);
                    },
                    child: Text('Vote Beta'),
                    style: ElevatedButton.styleFrom(shape: StadiumBorder()),
                  )
                ],
              )
            ],
          ),
        ),
      );
  }
}
    


  
