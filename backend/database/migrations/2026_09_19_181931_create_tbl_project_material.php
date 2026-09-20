```php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('tbl_projectMaterial', function (Blueprint $table) {
            $table->bigIncrements('v_projectMaterialId');

            $table->unsignedBigInteger('v_projectId');

            $table->unsignedBigInteger('v_materialId');

            $table->decimal('v_estimatedQuantity', 14, 2)
                ->nullable();

            $table->decimal('v_actualQuantity', 14, 2)
                ->nullable();

            $table->decimal('v_unitPrice', 14, 2)
                ->nullable();

            // Generated column
            // PostgreSQL requires quoted mixed-case column names.
            $table->decimal('v_totalEstimatedAmount', 14, 2)
                ->storedAs(
                    'COALESCE("v_estimatedQuantity", 0) * COALESCE("v_unitPrice", 0)'
                );

            $table->text('v_notes')
                ->nullable();

            // Project relationship
            $table->foreign(
                'v_projectId',
                'fk_projectMaterial_project'
            )
                ->references('v_projectId')
                ->on('tbl_project')
                ->onUpdate('cascade')
                ->onDelete('cascade');

            // Material relationship
            $table->foreign(
                'v_materialId',
                'fk_projectMaterial_material'
            )
                ->references('v_materialId')
                ->on('tbl_material')
                ->onUpdate('cascade')
                ->onDelete('restrict');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('tbl_projectMaterial');
    }
};
