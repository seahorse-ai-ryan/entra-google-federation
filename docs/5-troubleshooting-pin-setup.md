# 5. Disabling Mandatory PIN Setup (Windows Hello)

## The Problem

By default, Windows 11 forces users to set up a PIN during the Out-of-Box Experience (OOBE), even when signing in with federated Google credentials. This is annoying and confusing for users who just want to use their Google password.

**Good news:** You can disable this requirement with a simple API call. No paid license required.

---

## The Solution: Disable Windows Hello Enrollment Policy

This is a one-time administrative task that takes about 5 minutes. You'll use Microsoft's Graph Explorer tool to update a policy setting in your Entra tenant.

### **What You're Actually Doing**

When you follow these steps, you're:
1. **Signing in** to Microsoft Graph Explorer with your Global Administrator account
2. **Granting permission** for the tool to modify feature rollout policies on your behalf
3. **Sending an update command** to disable the Windows Hello enrollment policy for your entire tenant

This is safe, reversible, and doesn't require any paid licenses beyond your existing Entra ID setup.

---

## **Step-by-Step Instructions**

### **Step 1: Open Graph Explorer**

1. Go to https://developer.microsoft.com/en-us/graph/graph-explorer
2. Click **Sign in to Graph Explorer** in the top-right corner
3. Sign in with your Global Administrator account (e.g., `admin@<your-tenant>.onmicrosoft.com`)

### **Step 2: Grant Permission**

1. After signing in, you'll see a consent screen requesting permissions
2. Look for **Policy.ReadWrite.FeatureRollout** in the list
3. Check the box and click **Consent**

**What this does:** You're giving Graph Explorer a temporary, limited-time key to act on your behalf, specifically to change feature rollout policies. This permission only lasts for your current session.

### **Step 3: Change the HTTP Method**

1. In Graph Explorer, look for the dropdown menu that says **GET** (top-left of the query box)
2. Click it and change it to **PATCH**

**Why PATCH?**
- **GET** reads data (like viewing a setting)
- **POST** creates new data (like adding a new policy)
- **PATCH** updates existing data (like changing a setting)

We're updating an existing policy, so we use **PATCH**.

### **Step 4: Enter the API URL**

1. In the query box, paste this URL:
   ```
   https://graph.microsoft.com/v1.0/directory/featureRolloutPolicies/a03b5c1e-5f6e-4b9a-8c9d-1e2f3a4b5c6d
   ```

**What this URL means:** This is the unique, permanent address for the specific policy object that controls Windows Hello enrollment for your entire tenant. Every Entra tenant has this same policy ID.

### **Step 5: Enter the Request Body**

1. Look for the **Request body** section below the query box
2. Paste this JSON code:
   ```json
   {
     "isEnabled": false
   }
   ```

**What this does:** You're sending a direct instruction to the policy object at that URL: "Change your `isEnabled` property to `false`." This turns off mandatory Windows Hello enrollment.

### **Step 6: Run the Query**

1. Click the blue **Run query** button
2. Wait for the response

**Success indicator:** You should see a **204 No Content** response in the response pane.

**What "204 No Content" means:** This is the standard success code for update operations. It means, "I have successfully made the change you requested and have nothing to report back." If you see this, it worked!

### **Step 7: Verify (Optional)**

To confirm the policy is disabled:
1. Change the method back to **GET**
2. Keep the same URL
3. Click **Run query**
4. You should see `"isEnabled": false` in the response

---

## **What Happens Next**

- **Immediate effect:** The policy change is active right away
- **New devices:** Users setting up new Windows laptops will no longer be forced to create a PIN
- **Existing devices:** This doesn't change anything for devices that are already set up
- **Reversible:** You can re-enable this anytime by sending `{"isEnabled": true}` instead

---

## **Understanding the Technical Details**

### **HTTP Methods Explained**

| Method | Purpose | Example |
|--------|---------|---------|
| **GET** | Read/view data | "Show me the current policy setting" |
| **POST** | Create new data | "Create a new policy object" |
| **PATCH** | Update existing data | "Change this policy's isEnabled flag" |
| **DELETE** | Remove data | "Delete this policy" |

### **The Policy ID**

The URL `https://graph.microsoft.com/v1.0/directory/featureRolloutPolicies/a03b5c1e-5f6e-4b9a-8c9d-1e2f3a4b5c6d` contains:
- `graph.microsoft.com/v1.0` - The Microsoft Graph API endpoint
- `directory/featureRolloutPolicies/` - The collection of feature rollout policies
- `a03b5c1e-5f6e-4b9a-8c9d-1e2f3a4b5c6d` - The specific ID for the Windows Hello enrollment policy (same for all tenants)

### **The Request Body**

```json
{
  "isEnabled": false
}
```

This JSON (JavaScript Object Notation) is a simple key-value pair:
- **Key:** `isEnabled` (the property we're changing)
- **Value:** `false` (the new value we want)

### **The Response Code**

- **204 No Content** - Success! Change applied, nothing to return
- **403 Forbidden** - Permission denied (need to consent to the permission)
- **404 Not Found** - Invalid policy ID (double-check the URL)
- **400 Bad Request** - Syntax error in your JSON (check for typos)

---

## **Troubleshooting**

### **I get a 403 Forbidden error**

**Solution:** You need to consent to the `Policy.ReadWrite.FeatureRollout` permission:
1. Click **Modify permissions** in Graph Explorer
2. Find `Policy.ReadWrite.FeatureRollout`
3. Click **Consent**
4. Try the query again

### **I get a 400 Bad Request error**

**Solution:** Check your JSON syntax:
- Make sure you have curly braces: `{ }`
- Quotes around both the key and value: `"isEnabled": false`
- No comma at the end (since there's only one property)
- `false` is lowercase, no quotes around it

### **I don't see Graph Explorer**

**Solution:** Make sure you're signed in:
1. Look for your profile picture in the top-right corner of Graph Explorer
2. If you see "Sign in," click it and authenticate
3. After signing in, try the steps again

### **How do I undo this change?**

**Solution:** Follow the same steps but use:
```json
{
  "isEnabled": true
}
```

---

## **Why This Is Safe**

1. **No paid license required:** This uses the free Graph API access included with your Entra tenant
2. **Scoped permission:** You're only granting permission to modify feature rollout policies, nothing else
3. **Temporary session:** The permission token expires when you close Graph Explorer
4. **Reversible:** You can re-enable the policy at any time
5. **Targeted change:** This only affects Windows Hello enrollment, not security policies or user data
6. **Standard practice:** This is a documented Microsoft Graph API operation

---

## **Additional Resources**

- **Microsoft Graph API Documentation:** https://learn.microsoft.com/en-us/graph/api/resources/featurerolloutpolicy
- **Graph Explorer:** https://developer.microsoft.com/en-us/graph/graph-explorer
- **HTTP Status Codes:** https://developer.mozilla.org/en-US/docs/Web/HTTP/Status

---

## **When to Use This**

✅ **Use this if:**
- You want to simplify the OOBE experience for federated users
- Your users find PIN setup confusing or unnecessary
- You want users to sign in with their Google password only

⚠️ **Consider keeping PIN setup if:**
- You have strict security policies requiring multi-factor authentication at the device level
- Your organization is subject to compliance requirements that mandate PINs
- You want the convenience of Windows Hello biometric authentication (fingerprint/face)

