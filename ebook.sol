pragma solidity ^0.4.11;
import "github.com/Arachnid/solidity-stringutils/strings.sol";

/**
 * Manage & Preserve eBook ownership via Ethereum smart contract to widen, utilize eBook market.
 * 
 * TODO: Separate into multiple contracts
 * TODO: Add ownership transfer function
 * TODO: Manage list of published eBooks with its' ISBN on contract
 * TODO: Build Swarm-based decentralized eBook market
 */
contract Ebook {
    using strings for *;

    address public admin;
    mapping(address => Seller) public sellers;
    mapping(address => Customer) public customers;
    
    modifier isAdmin {
        require(msg.sender == admin);
        _;
    }
    modifier isSeller {
        require(sellers[msg.sender].exists);
        _;
    }

    struct Seller {
        string name;
        string contact;
        bool exists;
    }
    struct Customer {
        string name;
        string contact;
        mapping(uint => PurchasedBook) books;
    }
    struct PurchasedBook {
        address seller;
        bool exists;
    }

    function Ebook() {
        admin = msg.sender;
    }

    /**
     * @dev Register eBook seller.
     * @param seller Address of the seller
     * @param name Name of the seller
     * @param name Contact of the seller
     */
    function registerSeller(address seller, string name, string contact) isAdmin {
        require(!sellers[seller].exists); // Should not register duplicate seller
        sellers[seller] = Seller({
            name: name,
            contact: contact,
            exists: true
        });
    }

    /**
     * @dev Deregister eBook seller
     * @param seller Address of the seller
     */
    function deregisterSeller(address seller) isAdmin {
        require(sellers[seller].exists); // Seller should have been registered
        delete sellers[seller];
    }

    /**
     * @dev Seller registers book to the user whom bought
     * @param customer Address of the customer
     * @param isbn ISBN number of the eBook
     */
    function registerBook(address customer, uint isbn) isSeller {
        validateIsbn(isbn);
        require(!validateOwnership(customer, isbn)); // Should not own duplicate book
        customers[customer].books[isbn].seller = msg.sender;
        customers[customer].books[isbn].exists = true;
    }

    /**
     * @dev Get seller address of the purchased book
     * @param customer Address of the customer
     * @param isbn ISBN number of the eBook
     * @return seller Address of ther seller
     */
    function getBookSeller(address customer, uint isbn) constant public returns (address seller) {
        validateIsbn(isbn);
        require(validateOwnership(customer, isbn)); // Customer should own the book
        return customers[customer].books[isbn].seller;
    }

    /**
     * @dev Unregister customer's eBook, in case of refund.
     * @param customer Address of the customer
     * @param isbn ISBN number of the eBook
     */
    function unregisterBook(address customer, uint isbn) isSeller {
        validateIsbn(isbn);
        require(validateOwnership(customer, isbn)); // Should own the book
        delete customers[customer].books[isbn];
    }

    /**
     * @dev Validate ISBN format
     * @param isbn ISBN number of the eBook
     * 
     * TODO: Enhance validation logic
     */
    function validateIsbn(uint isbn) {
        require(isbn > 9780000000000 && isbn < 9799999999999);
    }

    /**
     * @dev Validate ownership of the eBook by it's ISBN
     * @param customer Address of the customer
     * @param isbn ISBN number of the eBook
     */
    function validateOwnership(address customer, uint isbn) constant internal returns (bool) {
        validateIsbn(isbn);
        return customers[customer].books[isbn].exists;
    }
}
