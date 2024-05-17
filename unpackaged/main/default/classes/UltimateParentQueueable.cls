/**********************************************************
Class: UltimateParentQueueable 
LastModifiedBy: Bopsy 05/04/2023
Description: Queuable class to update Ultimate Parent
TestClass : AccountTriggerHandlerTest
***********************************************************/
public class UltimateParentQueueable implements Queueable {
    
    private List<Account> theAccList;
    
    public UltimateParentQueueable(List<Account> theAccList) {
        this.theAccList = theAccList;
    }
    
    public void execute(QueueableContext context) { 
        
        // User AccountHierarchyTree to query, put into trees, and update ultimate parent
        // Then return all accounts for update
        Set<Id> allAccountIds = new Set<Id>();
        allAccountIds.addAll(new Map<Id,Account>(theAccList).keySet());
        List<AccountHierarchyTree> hierarchies = new List<AccountHierarchyTree>();
        buildTreesFromList(hierarchies,theAccList);
        
        Set<Id> parentIds = new Set<Id>();
        Set<Id> accountIds = new Set<Id>();
        for(AccountHierarchyTree tree: hierarchies){
            ParentIds.addAll(tree.getParentIds());
            accountIds.addAll(tree.getAccountIds());
        }
        
        List<Account> newNodes = parentsAndChildrenQuery(parentIds, accountIds, allAccountIds);
        while(!newNodes.isEmpty()){
            allAccountIds.addAll(new Map<Id,Account>(newNodes).keySet());
            buildTreesFromList(hierarchies,newNodes);
            
            // merge trees
            hierarchies = mergeTrees(hierarchies);
            
            // Get new accounts
            for(AccountHierarchyTree tree: hierarchies){
                ParentIds.addAll(tree.getParentIds());
                accountIds.addAll(tree.getAccountIds());
            } 
            newNodes = parentsAndChildrenQuery(parentIds, accountIds, allAccountIds);
        }
        
        // populate ultimate parents
        //List<Account> accountsToUpdate = new List<Account>();
        Map<Id, Account> accountsToUpdateMap = new Map<Id, Account>();
        
        Set<Id> theUltimateParentIdsSet = new Set<Id>();
        for(AccountHierarchyTree tree: hierarchies){
            tree.populateUltimateParent();
            // populate HierarchyLevel Depth
            tree.populateHierarchyLevel();
            // populate Total Child Location
            tree.populateTotalChildLocations();
            List<Account> treeAccounts = tree.getAccounts();
            theUltimateParentIdsSet.add(treeAccounts.get(0).Id);
            
            for(Account node: treeAccounts){
                //populate Hierarchy Adjusted for Ultimate parent Only
                if(treeAccounts.get(0).Id == node.Id){
                    node.Hierarchy_Adjusted__c = true;
                } 
                accountsToUpdateMap.put(node.Id,node);
            }     
              
        }
        
        update accountsToUpdateMap.values();

        Map<Id,Account> theAcntUpdatesMap = CommonClassToUpdateBecameCustomerDate.getAccountsToUpdateBecameCustomer(theUltimateParentIdsSet, 'Account');
        if(!theAcntUpdatesMap.isEmpty()){
            update theAcntUpdatesMap.values();
        }        
        
    }
    
    public List<Account> parentsAndChildrenQuery(Set<Id> parentIds, Set<Id> accountIds, Set<Id> exclusionIds){
        List<Account> otherAccounts = [Select id, Name,Type, ParentId, Ultimate_Parent__c, Became_a_Customer_Date__c From Account Where (Id IN :parentIds OR ParentId IN :accountIds) AND ID NOT IN :exclusionIds];
        return otherAccounts;
    }
    
    public void buildTreesFromList(List<AccountHierarchyTree> trees, List<Account> accts){
        
        for(Account acct: accts){
            Boolean added = false;
            for(AccountHierarchyTree tree: trees){
                if(tree.isAddable(acct)){
                    tree.addNode(acct);
                    added = true;
                } 
            }
            if(!added) trees.add(new AccountHierarchyTree(acct));
        }
    }
    
    public List<AccountHierarchyTree> mergeTrees(List<AccountHierarchyTree> trees){
        List<AccountHierarchyTree> newlist = new List<AccountHierarchyTree>();
        for(Integer treeItr=0;treeItr<trees.size();treeItr++){
            AccountHierarchyTree tree = trees.get(treeItr);
            Boolean merged = false;
            
            // go through all the new trees to merge first
            for(Integer newTreeItr=0;newTreeItr<newList.size();newTreeItr++){
                AccountHierarchyTree newTree = newList.get(newTreeItr);
                if(tree.getRoot().ParentId != null && newTree.getAccountIds().contains(tree.getRoot().ParentId)
                   || newTree.getRoot().ParentId != null && tree.getAccountIds().contains(newTree.getRoot().ParentId)){
                       newTree.mergeTrees(tree);
                       newList.set(newTreeItr,newTree);
                       merged = true;
                       
                   }
            }
            if(merged) continue;
            // go through all the remaining old trees
            for(Integer oldTreeItr=treeItr+1;oldTreeItr<trees.size();oldTreeItr++){
                AccountHierarchyTree oldTree = trees.get(oldTreeItr);
                if(tree.getRoot().ParentId != null && oldTree.getAccountIds().contains(tree.getRoot().ParentId)
                   || oldTree.getRoot().ParentId != null && tree.getAccountIds().contains(oldTree.getRoot().ParentId)){
                       oldTree.mergeTrees(tree);
                       trees.set(oldTreeItr,oldTree);
                       merged = true;
                   }
            } 
            if(merged) continue;
            newList.add(tree);
        }
        return newlist;
    }
 
}