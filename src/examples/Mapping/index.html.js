const html = `<p>Maps are created with the syntax <code>mapping(keyType =&gt; valueType)</code>.</p>
<p><code>keyType</code> can be value types such as <code>uint</code>, <code>address</code> or <code>bytes</code>.</p>
<p><code>valueType</code> can be any type.</p>
<p>Mappings are not iterable.</p>
<pre><code class="language-solidity">pragma solidity ^0.5.3;

contract Mapping {
    // Mapping from address to uint
    mapping(address =&gt; uint) public balances;
    // Nested mapping
    mapping(address =&gt; mapping(address =&gt; uint)) public allowance;

    function mint(uint amount) public {
        // Updating mapping values
        balances[msg.sender] += amount;
    }

    function burn() public {
        // Deleting mapping values
        delete balances[msg.sender];
    }

    function approve(address to, uint amount) public {
        // Accessing and setting nested map values
        allowance[msg.sender][to] = amount;
    }

    function transferFrom(address from, address to, uint amount) public {
        require(balances[from] &gt;= amount, "Insufficient funds");
        require(allowance[from][to] &gt;= amount, "Not allowed");

        balances[from] -= amount;
        balances[to] += amount;

        allowance[from][to] -= amount;
    }
}
</code></pre>
`

export default html
