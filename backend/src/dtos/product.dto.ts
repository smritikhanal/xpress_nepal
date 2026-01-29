/**
 * Product Data Transfer Objects
 * 
 * Defines the structure for product-related API requests.
 */

/**
 * Attributes for product variations
 */
export interface ProductAttributesDTO {
    color?: string;
    size?: string;
    weight?: string;
}

/**
 * DTO for creating a new product
 */
export interface CreateProductDTO {
    title: string;
    description: string;
    price: number;
    discountPrice?: number;
    categoryId: string;
    brand?: string;
    images?: string[];
    stock: number;
    attributes?: ProductAttributesDTO;
    // sellerId is automatically handled by the backend from the auth token
}

/**
 * DTO for updating an existing product
 */
export interface UpdateProductDTO {
    title?: string;
    description?: string;
    price?: number;
    discountPrice?: number;
    categoryId?: string;
    brand?: string;
    images?: string[];
    stock?: number;
    attributes?: ProductAttributesDTO;
    isActive?: boolean;
}
