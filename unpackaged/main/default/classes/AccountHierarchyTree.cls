/**********************************************************
Class: AccountHierarchyTree 
LastModifiedBy: Bopsy 04/27/2023
Description: This class is used for get the Ultimate Parent and child accounts 
TestClass : AccountHierarchyTreeTest
***********************************************************/
public class AccountHierarchyTree {
    
    private AccountNode root;
    private Map<Id,List<AccountNode>> parentMap;
    private Map<Id,AccountNode> accountIds;
    
    public AccountHierarchyTree(Account root){
        this.root = new AccountNode(root);
        parentMap = new Map<Id,List<AccountNode>>{this.root.AccountId=>new List<AccountNode>()};
        accountIds = new Map<Id,AccountNode>{this.root.AccountId=>this.root};
        if(this.root.ParentId != null) parentMap.put(this.root.ParentId, new List<AccountNode>());
    }
    
    public Account getRoot(){
        return getAccount(root);
    }
    
    public Account getParent(Account node){
        return getAccount(accountIds.get(node.ParentId));
    }
    
    public Account getAccount(AccountNode node){
        return new Account(Id=node.AccountId,Name=node.Name,ParentId=node.ParentId,Ultimate_Parent__c=node.UltimateParentId,Total_Child_Locations__c=node.TotalChildLocations,Type=node.AccountType,Hierarchy_Level__c=node.HierarchyLevel);
    }
    
    public Set<Id> getAccountIds(){
        return accountIds.keySet();
    }
    
    public Set<Id> getParentIds(){
        Set<Id> parentIds = new Set<Id>();
        parentIds.addAll(parentMap.keySet());
        if(root.ParentId != null) parentIds.add(root.ParentId);
        return parentIds;
    }
    
   
    public void addNode(Account node){
        
        //not constructed with a root
        if(root == null){
          root = new AccountNode(node);
           parentMap = new Map<Id,List<AccountNode>>{root.AccountId=>new List<AccountNode>()};
           accountIds = new Map<Id,AccountNode>{root.AccountId=>this.root};
            if(root.ParentId != null) parentMap.put(root.ParentId, new List<AccountNode>());
            return;
        } 
        
        // cannot replace root if current root has no parent
        if(!parentMap.containsKey(node.ParentId) && root.ParentId != node.Id) throw new AccountHierarchyTreeException('New Account: '+node.Name+', doesn\'t match other accounts in the hierarchy.');       
        
        AccountNode newNode = new AccountNode(node);
        parentMap.put(newNode.AccountId,new List<AccountNode>());
        accountIds.put(newNode.AccountId, newNode);
        
        
        // Add node as Child
        if(parentMap.containsKey(newNode.ParentId)){
            parentMap.get(newNode.ParentId).add(newNode);
        } 
        else{ // Add as new root
            parentMap.get(newNode.AccountId).add(root);
            root = newNode;
        }

    }
    
    public Integer getDepth(){
        return treeDepth(root);
    }
    
    public Integer getDepth(Id AccountId){
        return treeDepth(getNode(AccountId));
    }
    
    
    
    @TestVisible
    private AccountNode getNode(Id AccountId){
        return accountIds.get(AccountId);
    }
    
    @TestVisible
    private Integer treeDepth(AccountNode node){
        Integer depth = 1; // for the root
        if(!parentMap.containsKey(node.AccountId) || parentMap.get(node.AccountId).isEmpty()) return depth;
        
        Integer largestDepth = 0;
        for(AccountNode child: parentMap.get(node.AccountId)){
            Integer nodeDepth = treeDepth(child);
          if(largestDepth < nodeDepth) largestDepth = nodeDepth;
        }
        return depth + largestDepth;
    }
    
    public Integer getNumberOfNodes(){
        return numberOfNodes(root);
    }
    
    @TestVisible
    private Integer numberOfNodes(AccountNode node){
        // Add code that traverses tree returns total number of nodes (recursively)
         Integer depth = 1; // for the root
        if(!parentMap.containsKey(node.AccountId)) return depth;
        
        for(AccountNode child: parentMap.get(node.AccountId)){
          depth += numberOfNodes(child);    
        }
        return depth; 
    }
    
    public void mergeTrees(AccountHierarchyTree otherTree){
        
        if(otherTree.getParentIds().contains(root.ParentId)){
            // otherTree has a parent of our root
            for(Account node: getAccounts()) otherTree.addNode(node);
             this.root = null;
            parentMap = new Map<Id,List<AccountNode>>();
            accountIds = new Map<Id,AccountNode>();
            for(Account node: otherTree.getAccounts()) addNode(node);
        }
        else if(getParentIds().contains(otherTree.getRoot().ParentId)){
          // this tree has a parent of their root
          for(Account node: otherTree.getAccounts()) addNode(node);
        }
        else throw new AccountHierarchyTreeException('Merge failed due to non-addible account');
    }
    
    public void populateUltimateParent(){
        populateUltimateParent(root,root.AccountId);
    }
    
    public String printTree(){
        return printTree(root);
    }
    
    @testVisible
    private String printTree(AccountNode node){
        String printedTree = node.Name + ' \n';
        if(!parentMap.containsKey(node.AccountId) || parentMap.get(node.AccountId).isEmpty()) return printedTree;
        
        for( AccountNode child: parentMap.get(node.AccountId)){
            String depth = '\t';
            for(Integer dItr=0;dItr<node.HierarchyLevel;dItr++) depth += '\t';
            printedTree += depth + printTree(child);
        }
        return printedTree;
    }
    
    @testVisible
    private void populateUltimateParent(AccountNode root, Id UltimateParentId) {
        
        if(root != this.root) root.UltimateParentId = UltimateParentId;
        if(!parentMap.containsKey(root.AccountId)) return;
        
        for( AccountNode child: parentMap.get(root.AccountId)){
            populateUltimateParent(child, UltimateParentId);
        }
    }
    
    public void populateTotalChildLocations(){
        treeChildrenLocations(root);
    }
    
    @TestVisible
    private Integer treeChildrenLocations(AccountNode node){
        Integer locations = 0;
        
        // end of tree node condition
        if(!parentMap.containsKey(node.AccountId) || parentMap.get(node.AccountId).isEmpty()){
           if(node.AccountType == 'Practice Location') locations = 1;
           node.TotalchildLocations = locations;
           return locations;
        } 
        
        
        for(AccountNode child: parentMap.get(node.AccountId)){
          locations += treeChildrenLocations(child);
        }
        node.TotalChildLocations = locations;
        return locations;
    }
    
    public void populateHierarchyLevel(){
        populateHierarchyLevel(root);
    }
    
    @TestVisible
    private void populateHierarchyLevel(AccountNode node){
        if(node == root) node.HierarchyLevel = 1;
        else node.HierarchyLevel = accountIds.get(node.ParentId).HierarchyLevel + 1;
        
        if(!parentMap.containsKey(node.AccountId)) return;
        
        for( AccountNode child: parentMap.get(node.AccountId)){
            populateHierarchyLevel(child);
        }
    }
    
    public Boolean isAddable(Account node){
        if(accountIds.containsKey(node.id)) throw new AccountHierarchyTreeException('Account is already in tree.');
        return accountIds.containsKey(node.ParentId) || getParentIds().contains(node.Id);
    }
   
    
    public List<Account> getAccounts() {
        return getAccounts(root);
    }
    
    public List<Account> getAccounts(AccountNode node){
        List<Account> nodes = new List<Account>();
        nodes.add(getAccount(node));
        if(!parentMap.containsKey(node.AccountId)) return nodes;
        for(AccountNode child: parentMap.get(node.AccountId)){
          nodes.addAll(getAccounts(child));  
        }
        
        return nodes;
    }
    
    
    public class AccountNode {
        public Id AccountId;
        public Id ParentId;
        public Id UltimateParentId;
        public String Name;
        public String AccountType;
        public Integer TotalChildLocations;
        public Integer HierarchyLevel;
        
        public AccountNode(Account node){
            AccountId = node.Id;
            ParentId = node.ParentId;
            this.Name = node.Name;
            AccountType = node.type;
        }
    }
    
    public class AccountHierarchyTreeException extends Exception {}
    
}