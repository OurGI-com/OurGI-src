# OurGi-src
blockchain for group intelligence

OurGi mesh network:

![](./OurGi_mesh_network.png)

区块链只是DAO(去中心自治组织)的一种实现方式, 含Raft共识算法的分布式数据库应该是另一种可能更容易的DAO实现方式

如果能在Raft共识算法的前面插入回调钩子就可以调用任何语言比如php来检查sql语句是否符合预先设置的业务逻辑, 开发者就能形成一个表决网络来发布php应用

目前问题: CockroachDB的共识算法在写入kv之前而不是在发出sql之前, rqlite的共识算法在发出sql之前但不像cockroachdb分range能让网络内所有节点都参与, rqite典型网络最多9个节点参与表决, 其他节点都是只读节点(https://github.com/cockroachdb/cockroach/issues/48007)

IBM公司也有人想把CockroachDB和Hyperledger集成起来, 可以关注: https://wiki.hyperledger.org/display/INTERN/Enabling+CockroachDB+as+a+State+Database+for+Hyperledger+Fabric
