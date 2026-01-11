import 'dart:collection';
import 'package:flutter/material.dart';

// Thuật toán Dinic - giữ nguyên
class Edge {
  int to;
  int cap;
  int rev;

  Edge(this.to, this.cap, this.rev);
}

class Dinic {
  int n;
  List<List<Edge>> graph;
  List<int> level;
  List<int> it;

  Dinic(this.n)
      : graph = List.generate(n, (_) => []),
        level = List.filled(n, 0),
        it = List.filled(n, 0);

  void addEdge(int from, int to, int cap) {
    graph[from].add(Edge(to, cap, graph[to].length));
    graph[to].add(Edge(from, 0, graph[from].length - 1));
  }

  bool bfs(int s, int t) {
    level.fillRange(0, n, -1);
    Queue<int> q = Queue();
    level[s] = 0;
    q.add(s);

    while (q.isNotEmpty) {
      int v = q.removeFirst();
      for (var e in graph[v]) {
        if (e.cap > 0 && level[e.to] < 0) {
          level[e.to] = level[v] + 1;
          q.add(e.to);
        }
      }
    }
    return level[t] >= 0;
  }

  int dfs(int v, int t, int f) {
    if (v == t) return f;
    for (; it[v] < graph[v].length; it[v]++) {
      var e = graph[v][it[v]];
      if (e.cap > 0 && level[v] + 1 == level[e.to]) {
        int ret = dfs(e.to, t, f < e.cap ? f : e.cap);
        if (ret > 0) {
          e.cap -= ret;
          graph[e.to][e.rev].cap += ret;
          return ret;
        }
      }
    }
    return 0;
  }

  int maxFlow(int s, int t) {
    int flow = 0;
    const int INF = 1 << 30;

    while (bfs(s, t)) {
      it.fillRange(0, n, 0);
      int f;
      while ((f = dfs(s, t, INF)) > 0) {
        flow += f;
      }
    }
    return flow;
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dinic Max Flow Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MaxFlowPage(),
    );
  }
}

class MaxFlowPage extends StatefulWidget {
  const MaxFlowPage({super.key});

  @override
  State<MaxFlowPage> createState() => _MaxFlowPageState();
}

class _MaxFlowPageState extends State<MaxFlowPage> {
  final TextEditingController _nController = TextEditingController(text: '7');
  final TextEditingController _mController = TextEditingController(text: '12');
  final TextEditingController _sourceController = TextEditingController(text: '6');
  final TextEditingController _sinkController = TextEditingController(text: '7');
  
  List<EdgeInput> _edges = [];
  String? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Khởi tạo với dữ liệu mẫu
    _edges = [
      EdgeInput(1, 7, 7),
      EdgeInput(2, 3, 6),
      EdgeInput(2, 5, 6),
      EdgeInput(3, 1, 6),
      EdgeInput(3, 7, 11),
      EdgeInput(4, 1, 7),
      EdgeInput(4, 2, 4),
      EdgeInput(4, 5, 5),
      EdgeInput(5, 1, 4),
      EdgeInput(5, 3, 4),
      EdgeInput(6, 2, 8),
      EdgeInput(6, 4, 10),
    ];
  }

  @override
  void dispose() {
    _nController.dispose();
    _mController.dispose();
    _sourceController.dispose();
    _sinkController.dispose();
    for (var edge in _edges) {
      edge.dispose();
    }
    super.dispose();
  }

  void _calculateMaxFlow() {
    setState(() {
      _result = null;
      _error = null;
    });

    try {
      final n = int.parse(_nController.text);
      final source = int.parse(_sourceController.text);
      final sink = int.parse(_sinkController.text);

      if (n < 1) {
        setState(() => _error = 'Số nút phải >= 1');
        return;
      }

      if (source < 1 || source > n || sink < 1 || sink > n) {
        setState(() => _error = 'Source và Sink phải trong khoảng [1, $n]');
        return;
      }

      if (source == sink) {
        setState(() => _error = 'Source và Sink không được trùng nhau');
        return;
      }

      Dinic dinic = Dinic(n);
      
      for (var edgeInput in _edges) {
        final from = edgeInput.from;
        final to = edgeInput.to;
        final cap = edgeInput.capacity;
        
        if (from < 1 || from > n || to < 1 || to > n) {
          setState(() => _error = 'Cạnh ($from, $to) có nút ngoài phạm vi [1, $n]');
          return;
        }
        
        if (cap < 0) {
          setState(() => _error = 'Khả năng thông qua phải >= 0');
          return;
        }
        
        dinic.addEdge(from - 1, to - 1, cap); // Convert to 0-based
      }

      final maxFlow = dinic.maxFlow(source - 1, sink - 1); // Convert to 0-based
      
      setState(() {
        _result = 'Max Flow: $maxFlow';
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi: ${e.toString()}';
      });
    }
  }

  void _addEdge() {
    setState(() {
      _edges.add(EdgeInput(1, 2, 1));
    });
  }

  void _removeEdge(int index) {
    setState(() {
      _edges[index].dispose();
      _edges.removeAt(index);
    });
  }

  void _updateM() {
    final m = int.tryParse(_mController.text) ?? 0;
    if (m < 0) {
      _mController.text = '0';
      return;
    }
    while (_edges.length < m) {
      _addEdge();
    }
    while (_edges.length > m) {
      _removeEdge(_edges.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Dinic Max Flow Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin đồ thị',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _nController,
                            decoration: const InputDecoration(
                              labelText: 'Số nút (n)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _mController,
                            decoration: const InputDecoration(
                              labelText: 'Số cạnh (m)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (_) => _updateM(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _sourceController,
                            decoration: const InputDecoration(
                              labelText: 'Source (1-based)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextField(
                            controller: _sinkController,
                            decoration: const InputDecoration(
                              labelText: 'Sink (1-based)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Danh sách cạnh',
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              ElevatedButton.icon(
                                onPressed: _addEdge,
                                icon: const Icon(Icons.add),
                                label: const Text('Thêm cạnh'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ...List.generate(_edges.length, (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _edges[index].fromController,
                                      decoration: const InputDecoration(
                                        labelText: 'Từ',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _edges[index].toController,
                                      decoration: const InputDecoration(
                                        labelText: 'Đến',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextField(
                                      controller: _edges[index].capController,
                                      decoration: const InputDecoration(
                                        labelText: 'Capacity',
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeEdge(index),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed: _calculateMaxFlow,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Tính Max Flow',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_error != null)
                        Card(
                          color: Colors.red.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _error!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ),
                      if (_result != null)
                        Card(
                          color: Colors.green.shade50,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              _result!,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade900,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EdgeInput {
  final TextEditingController fromController;
  final TextEditingController toController;
  final TextEditingController capController;

  EdgeInput(int from, int to, int capacity)
      : fromController = TextEditingController(text: from.toString()),
        toController = TextEditingController(text: to.toString()),
        capController = TextEditingController(text: capacity.toString());

  int get from => int.parse(fromController.text);
  int get to => int.parse(toController.text);
  int get capacity => int.parse(capController.text);

  void dispose() {
    fromController.dispose();
    toController.dispose();
    capController.dispose();
  }
}
